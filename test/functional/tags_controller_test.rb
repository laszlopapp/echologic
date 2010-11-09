require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  def setup
    login_as :ben
    @controller = TagsController.new
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  test "should show tag" do
    get :show, :id => tags(:energy).to_param
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => tags(:energy).to_param
    assert_response :success
  end

  test "should create tag" do
    assert_difference('Tag.count') do
      post :create, :tag => { :value => "slingshot"}
    end
    assert_redirected_to hash_for_tags_path({:action => :show, :id => assigns(:tag).id})
  end

  test "should update tag" do
    put :update, :id => tags(:energy).to_param, :tag => {:value => "earthwindandfire"}
    assert_redirected_to hash_for_tags_path({:action => :show, :id => assigns(:tag).id})
  end

  test "should destroy tag" do
    assert_difference('Tag.count', -1) do
      delete :destroy, :id => tags(:energy).to_param
    end
    assert_redirected_to tags_path
  end
end
