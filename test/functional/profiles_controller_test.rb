require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @controller = Users::ProfilesController.new
  end
  
  test "should get show" do
    get :show, :id => profiles(:user_profile).id
    assert_response :success
  end
  
  test "should get details" do
    get :details, :id => profiles(:user_profile).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => profiles(:user_profile).to_param
    assert_response :success
  end
  
  test "should update profile" do
    put :update, :id => profiles(:user_profile).to_param, :profile => {:full_name => "Joe Doe" }
  end  
end
