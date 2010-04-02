require 'test_helper'

class WebAddressesControllerTest < ActionController::TestCase
  def setup
    @controller = WebAddressesController.new
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
    assert_difference('WebProfile.count') do
      post :create, :web_address => { }
    end

    assert_redirected_to web_address_path(assigns(:web_address))
  end

  test "should show web_address" do
    get :show, :id => web_addresses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => web_addresses(:one).to_param
    assert_response :success
  end

  test "should update web_address" do
    put :update, :id => web_addresses(:one).to_param, :web_address => { }
    assert_redirected_to web_address_path(assigns(:web_address))
  end

  test "should destroy web_address" do
    assert_difference('WebProfile.count', -1) do
      delete :destroy, :id => web_addresses(:one).to_param
    end

    assert_redirected_to web_addresses_path
  end
end
