require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as :user
    @controller = Users::PasswordResetsController.new
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should get edit" do
    get :edit
    assert_response :redirect
  end
  
  test "should get create" do
    post :create, :email => users(:user).email
    assert !ActionMailer::Base.deliveries.empty?
  end
  
 
end
