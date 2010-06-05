require 'test_helper'

class StatementTest < ActiveSupport::TestCase
  context "a statement" do
    should_have_many :statement_nodes
    should_have_many :statement_documents
  end
end
