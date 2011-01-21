require 'test_helper'

class StatementTest < ActiveSupport::TestCase
  
  context "a statement" do
    
    setup { @statement = Statement.new }
    subject { @statement }
    
    should have_many :statement_nodes
    should have_many :statement_documents
    should have_many :tao_tags
    should_have_many :tags
      
    # validates no invalid states
    [nil, "invalid state"].each do |value|
      context("with state set to #{value}") do
        setup {
          @statement.send("editorial_state_id=", value)
          assert ! @statement.valid?
        }
        should("include state in it's errors") {
          assert @statement.errors["editorial_state_id"]
        }
      end
    end
    
    # check for validations (should_validate_presence_of didn't work)
    %w(editorial_state_id).each do |attr|
      context "with no #{attr} set" do
        setup { @statement.send("#{attr}=", nil)
          assert ! @statement.valid?
        }
        should("include #{attr} in it's errors") {
          assert @statement.errors[attr]
        }
      end
    end
      
    should "be able to access its authors" do
      @statement = StatementDocument.find_by_title("Test Question?").statement
      @authors = @statement.authors
      assert @authors.length, 1
      assert @authors[0], User.find_by_email("editor@echologic.org")
    end
  end
end
