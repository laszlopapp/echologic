require 'test_helper'

class StatementTest < ActiveSupport::TestCase
  context "a statement" do
    should have_many :statement_nodes
    should have_many :statement_documents
  end
end
