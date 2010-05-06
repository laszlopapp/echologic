require 'test_helper'

class WebAddressesControllerTest < ActionController::TestCase
  def setup
    login_as :illiterate
    @controller = Users::WebAddressesController.new
  end
  
  test "should get new" do
    get :new
    assert_response (:error, "template new missing")
  end

  test "should create web_address" do
    assert_difference('WebAddress.count') do
      post :create, :web_address => {:web_address_id => WebAddress.web_addresses.id, :location => 'wiri@coco.com'} 
    end

  end

  test "should show web_address" do
    get :show, :id => web_addresses(:user_blog).to_param
    assert_response (:error, "template show missing")
  end

  test "should get edit" do
    get :edit, :id => web_addresses(:user_blog).to_param
    assert_response :success
  end

  test "should update web_address" do
    put :update, :id => web_addresses(:user_blog).to_param, :web_address => {:location => "blogadores.blogspot.com" }
  end

  test "should destroy web_address" do
    assert_difference('WebAddress.count', -1) do
      delete :destroy, :id => web_addresses(:user_blog).to_param
    end
  end
end
