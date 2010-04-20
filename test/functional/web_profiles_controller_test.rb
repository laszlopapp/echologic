require 'test_helper'

class WebProfilesControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @controller = Users::WebProfilesController.new
  end
  
  test "should get new" do
    get :new
    assert_response :error
  end

  test "should create web_profile" do
    assert_difference('WebProfile.count') do
      post :create, :web_profile => {:sort => 0, :location => 'xixi@coco.com'}
    end
  end

  test "should show web_profile" do
    get :show, :id => web_profiles(:user_blog).to_param
    assert_response :error
  end

  test "should get edit" do
    get :edit, :id => web_profiles(:user_blog).to_param
    assert_response :success
  end

  test "should update web_profile" do
    put :update, :id => web_profiles(:user_blog).to_param, :web_profile => {:location => "blogadores.blogspot.com" }
  end

  test "should destroy web_profile" do
    assert_difference('WebProfile.count', -1) do
      delete :destroy, :id => web_profiles(:user_blog).to_param
    end
  end
end
