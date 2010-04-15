require 'test_helper'

class SpokenLanguagesControllerTest < ActionController::TestCase
  def setup
    @controller = SpokenLanguagesController.new
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:spoken_languages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create spoken language" do
    assert_difference('SpokenLanguage.count') do
      post :create, :spoken_language => { }
    end

    assert_redirected_to spoken_language_path(assigns(:spoken_language))
  end

  test "should show spoken_language" do
    get :show, :id => spoken_languages(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => spoken_languages(:one).to_param
    assert_response :success
  end

  test "should update spoken language" do
    put :update, :id => spoken_languages(:one).to_param, :spoken_language => { }
    assert_redirected_to spoken_languages_path(assigns(:spoken_language))
  end

  test "should destroy spoken language" do
    assert_difference('WebProfile.count', -1) do
      delete :destroy, :id => spoken_languages(:one).to_param
    end

    assert_redirected_to spoken_languages_path
  end
  
 
end
