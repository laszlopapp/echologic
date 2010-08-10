require 'test_helper'

class ProposalsControllerTest < ActionController::TestCase
  
  def setup
    login_as :ben
    @statement_node = statement_nodes('first-proposal')
    @statement_node.children.first.update_attributes(:drafting_state => "approved")
    @controller = ProposalsController.new
  end
  
  test "should get incorporation form" do
    get :incorporate, :id => statement_nodes('first-proposal').to_param
    assert_response :success
  end

end
