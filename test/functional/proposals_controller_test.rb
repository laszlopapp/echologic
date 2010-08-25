require 'test_helper'

class ProposalsControllerTest < ActionController::TestCase

  def setup
    login_as :ben
    @statement_node = statement_nodes('first-proposal')
    @ip_node = statement_nodes('first-impro-proposal')
    @ip_node.update_attributes(:drafting_state => "approved")
    @controller = ProposalsController.new
  end

  test "should get incorporation form" do
    get :incorporate, :id => @statement_node.id, :approved_ip => @ip_node.id
    assert_response :success
  end

end
