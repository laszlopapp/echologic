require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  def setup
    login_as :editor
    @controller = DiscussionsController.new
  end

  test "should get My Discussions" do
    get :my_discussions
    assert_response :success
  end

  test "should publish non published debate" do
    prev_published = StatementNode.published(false).count
    put :publish, :id => statement_nodes(:non_published_discussion).to_param
    assert_equal StatementNode.published(false).count, prev_published+1
  end
  
  test "should get the statement node authors" do
    @statement_node = Discussion.first
    get :authors,:id => @statement_node.id
    assert_response :success
  end
end
