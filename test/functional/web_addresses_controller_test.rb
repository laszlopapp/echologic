require 'test_helper'

class WebAddressesControllerTest < ActionController::TestCase
  def setup
    @controller = Users::WebAddressesController.new
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:web_addresses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create web_address" do
    assert_difference('WebAddress.count') do
      post :create, :web_address => {:sort => 0, :location => 'wiri@coco.com' }
    end

    assert_redirected_to web_address_path(assigns(:web_address))
  end

  test "should show web_address" do
    get :show, :id => web_addresses(:user_blog).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => web_addresses(:user_blog).to_param
    assert_response :success
  end

  test "should update web_address" do
    put :update, :id => web_addresses(:user_blog).to_param, :web_address => {:location => "blogadores.blogspot.com" }
    assert_redirected_to web_address_path(assigns(:web_address))
  end

  test "should destroy web_address" do
    assert_difference('WebAddress.count', -1) do
      delete :destroy, :id => web_addresses(:user_blog).to_param
    end
    assert_redirected_to web_addresses_path
  end
end
