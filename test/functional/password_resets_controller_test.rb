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
  
  test "should get create" do
    post :create, :email => users(:user).email
    assert !ActionMailer::Base.deliveries.empty?
  end
  
  test "should get edit" do
    get :edit
    assert_response :redirect
  end 
  
  test "update fails when i do not fill any fields" do
    post :update, :id => users(:user).perishable_token, :user => {:password => "", :password_confirmation => ""}
    assert_not_nil assigns(:error)
    assert assigns(:error).include?("email")
    assert assigns(:error).include?("email_confirmation")
  end
  
  test "update fails when i do not fill password confirmation" do
    post :update, :id => users(:user).perishable_token, :user => {:password => "pass", :password_confirmation => ""}
    assert_not_nil assigns(:error)
    assert !assigns(:error).include?("Password")
    assert assigns(:error).include?("Password confirmation")
  end
  
  test "update fails when i do not fill password" do
    post :update, :id => users(:user).perishable_token, :user => {:password => "", :password_confirmation => "pass"}
    assert_not_nil assigns(:error)
    assert assigns(:error).include?("Password")
    assert !assigns(:error).include?("Password confirmation")
  end
  
  test "update fails when password is different from confirmation" do
    post :update, :id => users(:user).perishable_token, :user => {:password => "mega", :password_confirmation => "pass"}
    assert_not_nil assigns(:error)
    assert assigns(:error).include?(I18n.t("activerecord.errors.messages.confirmation", :attribute => "Password Confirmation"))
  end
  
  test "update fails when password is too short" do
    post :update, :id => users(:user).perishable_token, :user => {:password => "pas", :password_confirmation => "pas"}
    assert_not_nil assigns(:error)
    assert assigns(:error).include?(I18n.t("activerecord.errors.messages.too_short", :attribute => "Password"))
  end
  
  test "update succeeds" do
    post :update, :id => users(:user).perishable_token, :user => {:password => "pass", :password_confirmation => "pass"}
    assert_nil assigns(:error)
    assert_not_nil assigns(:info)
    assert assigns(:info).include?(I18n.t("users.password_reset.messages.reset_success"))
  end
end
