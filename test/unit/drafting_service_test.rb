require 'test_helper'

class DraftingServiceTest < ActiveSupport::TestCase

  context "concerning the drafting service" do
    setup { @drafting_service = DraftingService.instance}
    subject { @drafting_service }
    context "when user supports the first improvement proposal" do
      setup {
        @user = users(:user)
        @statement = statement_nodes('first-impro-proposal')
        EchoService.instance.supported!(@statement, @user)
      }
      should("then this improvement proposal shall remain tracked") do
        assert @statement.tracked?
      end
    end

    context "when user supports the first improvement proposal and min_votes = 1" do
      setup {
        DraftingService.min_votes=1
        @user = users(:user)
        @statement = statement_nodes('first-impro-proposal')
        EchoService.instance.supported!(@statement, @user)
      }
      should("then this improvement proposal shall be ready ") do
        @statement.reload
        assert @statement.ready?
      end
      should("set a delayed task for test staged") do
        assert Delayed::Job.all.map{|d|d.name}.include?("TestForStagedJob")
      end
    end

    context "when user unsupports the second improvement proposal which is ready and ranking changes" do
      setup {
        @statement_1 = statement_nodes('first-impro-proposal')
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_1.find_or_create_echo.update_counter!

        @statement_2 = statement_nodes('second-impro-proposal')
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.find_or_create_echo.update_counter!
        @statement_2.readify!
        @statement_2.save
        DraftingService.min_votes=2
        EchoService.instance.unsupported!(@statement_2, users(:red))
      }
      should("track the former first improvement proposal") do
        @statement_2.reload
        assert @statement_2.tracked?
      end
    end
    context "user supports the second improvement proposal which is tracked and ranking changes" do
      setup {
        @statement_1 = statement_nodes('second-impro-proposal')
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_1.find_or_create_echo.update_counter!
        @statement_1.save

        @statement_2 = statement_nodes('first-impro-proposal')
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.find_or_create_echo.update_counter!
        @statement_2.readify!
        @statement_2.stage!
        @statement_2.save
        DraftingService.min_votes=2

        EchoService.instance.supported!(@statement_1, users(:luise))
        EchoService.instance.supported!(@statement_1, users(:green))
      }

      should(" readify the former second improvement proposal") do
        @statement_1.reload
        assert @statement_1.ready?
      end
      should(" readify the former first improvement proposal (that was staged)") do
        @statement_2.reload
        assert @statement_2.ready?
      end
      should("set a delayed task for test staged") do
        assert Delayed::Job.all.map{|d|d.name}.include?("TestForStagedJob")
      end
    end

    context "ready improvement proposal that went Tr unchanged" do
      setup {

        DraftingService.min_votes=2
        @statement_1 = statement_nodes('first-impro-proposal')
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_1.find_or_create_echo.update_counter!
        @statement_1.readify!
        @statement_1.state_since = Time.now
        @statement_1.save

        @statement_2 = statement_nodes('second-impro-proposal')
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.find_or_create_echo.update_counter!
        @statement_2.readify!
        @statement_2.stage!
        @statement_2.state_since = Time.now
        @statement_2.save

        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.parent.find_or_create_echo.update_counter!
        @statement_2.parent.save

        statement = StatementNode.find(@statement_1.id)
        act = TestForStagedJob.new(statement.id, statement.state_since)
        act.perform
      }

      should(" stage that improvement proposal") do
        @statement_1.reload
        assert StatementNode.find(@statement_1.id).staged?
      end
      should(" approve the staged improvement proposal with most votes") do
        @statement_2.reload
        assert StatementNode.find(@statement_2.id).approved?
      end
      should("send an approval email") do
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.length-2]
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal [@statement_2.original_document.author.email], email.to
        assert_equal "Your Improvement Proposal was Approved!", email.subject
      end
      should("set a delayed task for approval reminder email sending") do
        assert Delayed::Job.all.map{|d|d.name}.include?("ApprovalReminderMailJob")
      end
      should("send an approval notification email") do
        email = ActionMailer::Base.deliveries.last
        supporters = @statement_2.parent.supporters.select{|sup|sup.languages.include?(@statement_2.original_language)}
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal supporters.map{|u|u.email}, email.bcc
        assert_equal "An Improvement Proposal was approved for incorporation", email.subject
      end
      should("set a delayed task for test passed") do
        assert Delayed::Job.all.map{|d|d.name}.include?("TestForPassedJob")
      end
    end

    context "ready improvement proposal that went Tr unchanged for the second time" do
      setup {

        DraftingService.min_votes=2
        @statement_1 = statement_nodes('first-impro-proposal')
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_1.find_or_create_echo.update_counter!
        @statement_1.readify!
        @statement_1.state_since = Time.now
        @statement_1.save

        @statement_2 = statement_nodes('third-impro-proposal')
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.find_or_create_echo.update_counter!
        @statement_2.readify!
        @statement_2.stage!
        @statement_2.state_since = Time.now
        @statement_2.times_passed = 1
        @statement_2.save

        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.parent.find_or_create_echo.update_counter!
        @statement_2.parent.save

        statement = StatementNode.find(@statement_1.id)
        act = TestForStagedJob.new(statement.id, statement.state_since)
        act.perform
      }

      should(" stage that improvement proposal") do
        @statement_1.reload
        assert StatementNode.find(@statement_1.id).staged?
      end
      should(" approve the staged improvement proposal with most votes") do
        @statement_2.reload
        assert StatementNode.find(@statement_2.id).approved?
      end
      should("send an supporters approval email") do
        supporters = @statement_2.supporters.select{|sup|sup.speaks_language?(@statement_2.original_language, 'intermediate')}
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.length-2]
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal supporters.map{|u|u.email}, email.bcc
        assert_equal "You have the privilege to incorporate a Improvement Proposal!", email.subject
      end
      should("set a delayed task for approval reminder email sending") do
        assert Delayed::Job.all.map{|d|d.name}.include?("ApprovalReminderMailJob")
      end
      should("send an approval notification email") do
        email = ActionMailer::Base.deliveries.last
        supporters = @statement_2.parent.supporters.select{|sup|sup.languages.include?(@statement_2.original_language)}
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal supporters.map{|u|u.email}, email.bcc
        assert_equal "An Improvement Proposal was approved for incorporation", email.subject
      end
      should("set a delayed task for test passed") do
        assert Delayed::Job.all.map{|d|d.name}.include?("TestForPassedJob")
      end
    end

    context "approved improvement proposal that went Ta unchanged" do
      setup {

        DraftingService.min_votes=2
        @statement_1 = statement_nodes('first-impro-proposal')
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_1.find_or_create_echo.update_counter!
        @statement_1.readify!
        @statement_1.stage!
        @statement_1.approve!
        @statement_1.state_since = Time.now
        @statement_1.save

        @statement_2 = statement_nodes('second-impro-proposal')
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.find_or_create_echo.update_counter!
        @statement_2.readify!
        @statement_2.stage!
        @statement_2.state_since = Time.now
        @statement_2.times_passed = 1
        @statement_2.save

        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.parent.find_or_create_echo.update_counter!
        @statement_2.parent.save

        act = TestForPassedJob.new(@statement_1.id)
        act.perform
      }

      should(" stage that improvement proposal") do
        @statement_1.reload
        assert StatementNode.find(@statement_1.id).staged?
      end
      should("send passed email") do
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.length-3]
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal [@statement_1.original_document.author.email], email.to
        assert_equal "Improvement Proposal Approval Passed!", email.subject
      end
      should("set the next best staged to approved") do
        @statement_2.reload
        assert StatementNode.find(@statement_2.id).approved?
      end
    end

    context "approved improvement proposal that went Ta unchanged for the second time" do
      setup {

        DraftingService.min_votes=2
        @statement_1 = statement_nodes('third-impro-proposal')
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_1.user_echos << UserEcho.new(:echo => @statement_1.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_1.find_or_create_echo.update_counter!
        @statement_1.readify!
        @statement_1.stage!
        @statement_1.approve!
        @statement_1.state_since = Time.now
        @statement_1.save

        @statement_2 = statement_nodes('second-impro-proposal')
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.find_or_create_echo.update_counter!
        @statement_2.readify!
        @statement_2.stage!
        @statement_2.state_since = Time.now
        @statement_2.times_passed = 1
        @statement_2.save

        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.parent.user_echos << UserEcho.new(:echo => @statement_2.parent.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.parent.find_or_create_echo.update_counter!
        @statement_2.parent.save

        act = TestForPassedJob.new(@statement_1.id)
        act.perform
      }

      should(" reset that improvement proposal") do
        assert StatementNode.find(@statement_1.id).tracked?
      end
      should("send passed email") do
        supporters = @statement_1.supporters.select{|sup|sup.languages('advanced').include?(@statement_2.original_language)}
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.length-3]
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal supporters.map{|u|u.email}, email.bcc
        assert_equal "Improvement Proposal Approval Passed!", email.subject
      end
      should("set the next best staged to approved") do
        @statement_2.reload
        assert StatementNode.find(@statement_2.id).approved?
      end
    end

    context " improvement proposal incorporation in proposal" do
      setup {

        @statement_1 = statement_nodes('fourth-impro-proposal')
        @statement_1.readify!
        @statement_1.stage!
        @statement_1.approve!
        @statement_1.state_since = Time.now
        @statement_1.save

        @statement_2 = statement_nodes('first-proposal')
        old_doc = @statement_2.original_document

        @statement_2.original_document.update_attribute(:current, false)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:red), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:luise), :supported => true)
        @statement_2.user_echos << UserEcho.new(:echo => @statement_2.find_or_create_echo, :user => users(:green), :supported => true)
        @statement_2.find_or_create_echo.update_counter!
        @statement_2.add_statement_document :original_language_id => @statement_2.original_language.id,
                                            :title => old_doc.title,
                                            :text => old_doc.text + @statement_1.original_document.text,
                                            :statement_id => @statement_2.statement_id,
                                            :language_id => old_doc.language.id,
                                            :current => true,
                                            :author_id => @statement_1.original_document.author.id,
                                            :action_id => StatementHistory.statement_actions('incorporated').id,
                                            :old_document_id => old_doc.id,
                                            :incorporated_node_id => @statement_1.id
        @statement_2.save
      }

      should(" incorporate that improvement proposal") do
        @statement_1.reload
        assert @statement_1.incorporated?
      end
      should("send incorporated email") do
        @statement_2.reload
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.length-2]
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal [@statement_2.original_document.author.email], email.to
        assert_equal "Your Improvement Proposal was successfully incorporated!", email.subject
      end
      should("send incorporation notification") do
        @statement_2.reload
        supporters = @statement_2.supporters.select{|sup|sup.speaks_language?(@statement_2.original_language, 'intermediate')}
        email = ActionMailer::Base.deliveries.last
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal supporters.map{|u|u.email}, email.bcc
        assert_equal "A Proposal you support has been updated!", email.subject
      end
    end
  end
end