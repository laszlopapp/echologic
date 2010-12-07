require 'test_helper'

class ActsAsDoubleTest < ActiveSupport::TestCase
  
  context "a double statement node" do

    setup { @double_statement_node = ProArgument.new({:parent_id => statement_nodes('first-proposal')})}
    subject { @double_statement_node }

    should "have expected sub types" do
      assert @double_statement_node.class.expected_sub_types.kind_of?(Array)
    end
  end
  
end