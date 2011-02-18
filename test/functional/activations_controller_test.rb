require 'test_helper'

class ActivationsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as :user
    @controller = Users::ActivationsController.new
  end
  
  test "should get new" do
    get :new
    assert_response :redirect
  end
  
end
