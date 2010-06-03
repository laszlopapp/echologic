require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  def setup
    login_as :editor
    @controller = QuestionsController.new
  end

  test "should get My Discussions" do
    get :my_discussions
    assert_response :success
  end

  test "should publish non published debate" do
    prev_published = StatementNode.published(false).count
    put :publish, :id => statement_nodes(:non_published_question).to_param
    assert_equal StatementNode.published(false).count, prev_published+1
  end
end
