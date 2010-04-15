require 'test_helper'

class ConcernmentsControllerTest < ActionController::TestCase
  def setup
    @controller = Users::ConcernmentsController.new
    @user = Profile.find_by_first_name('User').user
    @tag = Tag.find_by_value('echonomyJAM')
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:concernments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create concernment" do
    assert_difference('Concernment.count', 1, "a concernment should be created") do
      post :create, :concernment => { :user => @user, :tag => @tag, :sort => 0 }
    end

    assert_redirected_to concernment_path(assigns(:concernment))
  end

  test "should show concernment" do
    get :show, :id => concernments(:joe_energy).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => concernments(:joe_energy).to_param
    assert_response :success
  end

  test "should update concernment" do
    put :update, :id => concernments(:joe_energy).to_param, :concernment => { }
    assert_redirected_to concernment_path(assigns(:concernment))
  end

  test "should destroy concernment" do
    assert_difference('Concernment.count', -1) do
      delete :destroy, :id => concernments(:joe_energy).to_param
    end

    assert_redirected_to concernments_path
  end
end
