require 'test_helper'

class DiscussControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    #login_as :user
    @controller = DiscussController.new
    login_as :user
  end

  test "should get index without being logged on" do
    get :index
    assert_response :success
  end


  test "should get roadmap without being logged on" do
    get :roadmap
    assert_response :success
  end
end
