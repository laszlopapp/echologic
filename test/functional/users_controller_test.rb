require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
#    login_as :user
    @controller = Users::UsersController.new
#    @user = users(:ben)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

 test "should get edit" do
   login_as :user
    get :edit, :id => users(:user).to_param
    assert_response :success
  end
  
end
