require 'test_helper'

class StatementNodeTest < ActiveSupport::TestCase


  context "a statement node" do

    setup { @statement_node = Question.new }
    subject { @statement_node }

    should_belong_to :statement, :creator, :editorial_state
    should_have_many :tao_tags
    should_have_many :statement_documents
    should_have_many :tags

    # should be visited and supported

    # validates no invalid states
    [nil, "invalid state"].each do |value|
      context("with state set to #{value}") do
        setup {
          @statement_node.send("editorial_state_id=", value)
          assert ! @statement_node.valid?
        }
        should("include state in it's errors") {
          assert @statement_node.errors["editorial_state_id"]
        }
      end
    end

    # check for validations (should_validate_presence_of didn't work)
    %w(creator_id editorial_state_id).each do |attr|
      context "with no #{attr} set" do
        setup { @statement_node.send("#{attr}=", nil)
          assert ! @statement_node.valid?
        }
        should("include #{attr} in it's errors") {
          assert @statement_node.errors[attr]
        }
      end
    end

    context("should be in a tree") do
      should_belong_to :root_statement
      should_have_db_columns :root_id, :parent_id
    end

    context("should be echoable") do
      should_have_db_columns :echo_id
      should_belong_to :echo
      should_have_many :user_echos
    end

    context "being saved" do
      setup do
        doc = @statement_node.add_statement_document({:title => 'A new Document',
                                                :text => 'with a very short body, dude!',
                                                :language => StatementDocument.languages.first, 
                                                :author => User.first,
                                                :action => StatementHistory.statement_actions("new"),
                                                :original_language_id => StatementDocument.languages.first.id})
        @statement_node.topic_tags = "bebe"
        @statement_node.creator = User.first
        @statement_node.editorial_state = StatementNode.statement_states('published')
        @statement_node.save!
      end

      should "be able to access its statement documents data" do
        assert_equal @statement_node.translated_document([StatementDocument.languages.first.id]).title, "A new Document"
        assert_equal @statement_node.translated_document([StatementDocument.languages.first.id]).text, "with a very short body, dude!"
      end

      should "have creator as supporter" do
        @user = @statement_node.creator
        assert(@statement_node.supported?(@user))
      end

      should "have have a creation event associated" do
        @events = @statement_node.events
        assert(@events.first.operation.eql?('new'))
        result = JSON.parse(@events.first.event)

        question = result['question']
        statement = question['statement']
        statement_documents = statement['statement_documents']
        title = statement_documents.first['title']
        assert(title.eql?('A new Document'))

        question = result['question']
        tao_tags = question['tao_tags']
        tag = tao_tags.first['tag']['value']

        assert(tag.eql?('bebe'))
      end

      should "should be followed by creator" do
        @user = @statement_node.creator 
        assert (@statement_node.followed_by?(@user) or Delayed::Job.last.name[9..22] == "add_subscriber")
      end

      should "be able to be visited" do
        @user = User.last
        @statement_node.visited!(@user)
        assert(@statement_node.visited?(@user))
      end

      should "be able to be supported" do
        @user = User.last
        @statement_node.visited!(@user)
        assert(@statement_node.visited?(@user))
      end

      should "be able to be followed" do
        @user = User.last
        @user.find_or_create_subscription_for(@statement_node)
        assert(@user.follows?(@statement_node))
      end

    end

  end # main context

end # test
