require 'test_helper'

class StatementTest < ActiveSupport::TestCase
  context "a statement" do
    should have_many :statement_nodes
    should have_many :statement_documents
      
      
    should "be able to access its authors" do
      @statement = StatementDocument.find_by_title("Test Discussion?").statement
      @authors = @statement.authors
      assert @authors.length, 1
      assert @authors[0], User.find_by_email("editor@echologic.org")
    end
  end
end
