require 'test_helper'

class SpokenLanguagesControllerTest < ActionController::TestCase
  def setup
    login_as :illiterate
    @controller = Users::SpokenLanguagesController.new
  end

  test "should create spoken language" do
    assert_difference('SpokenLanguage.count') do
      post :create, :spoken_language => {:language => SpokenLanguage.languages.first.id, :level => SpokenLanguage.language_levels.first.id}
    end
  end

  test "should get edit" do
    get :edit, :id => spoken_languages(:spokenlanguagefunctional).to_param
    assert_response :success
  end

  test "should update spoken language" do
    put :update, :id => spoken_languages(:spokenlanguagefunctional).to_param, :spoken_language => {:language => SpokenLanguage.languages("pt") }
  end

  test "should destroy spoken language" do
    assert_difference('SpokenLanguage.count', -1) do
      delete :destroy, :id => spoken_languages(:spokenlanguagefunctional).to_param
    end
  end


end
