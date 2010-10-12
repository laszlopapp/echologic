require 'test_helper'

class UserEchoTest < ActiveSupport::TestCase

  context "UserEcho" do
    setup {@user_echo = UserEcho.new}
    subject {@user_echo}
    should belong_to :echo
    should belong_to :user
    should have_db_column :visited 
    should have_db_column :supported

    context "being told to be created or updated" do
      context "when it does not exist already for the given echo" do
        before = UserEcho.count
        setup {@user_echo = UserEcho.create_or_update!(:user => User.first,
                                                       :echo => Echo.first,
                                                       :visited => true)}
#        should "be created" do 
#          assert_equal UserEcho.count, (before + 1)
#        end
        should_change(nil, :by => 1) do
          UserEcho.count
        end
        context "and being updated again" do
          before = UserEcho.count
          setup {@user_echo = UserEcho.create_or_update!(:user => User.first,
                                                         :echo => Echo.first,
                                                         :supported => true)}
#          should "remain the same" do                                               
#            assert_equal UserEcho.count, before
#          end 
          should_not_change(nil) do
            UserEcho.count
          end
        end
      end
    end
  end
end
