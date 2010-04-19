require 'test_helper'

class ActControllerTest < ActionController::TestCase
  
  def setup
    login_as :user
    @controller = ActController.new
  end
  
  test "should get roadmap" do
    get :roadmap
    assert_response :success
  end
end
