require 'test_helper'

class StatementHistoryTest < ActiveSupport::TestCase
 
  context "a statement history" do
    setup { @statement_history = StatementHistory.new }
    subject { @statement_history }
 
    should belong_to :statement
    should belong_to :statement_document
    should belong_to :author
    should belong_to :old_document
    should belong_to :incorporated_node
   
     # check for validations (should_validate_presence_of didn't work)
    %w(author_id action_id).each do |attr|
      context "with no #{attr} set" do 
        setup { @statement_history.send("#{attr}=", nil)
          assert ! @statement_history.valid?
        }
        should("include #{attr} in it's errors") { 
          assert @statement_history.errors[attr]
        }
      end
    end 
  end
end
