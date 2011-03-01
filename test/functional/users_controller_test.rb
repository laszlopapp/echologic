require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include FlexMock::TestCase


  def setup
#    login_as :user
    @controller = Users::UsersController.new
    profile_template = {'identifier' => "@asdas12dgfkj54oi", 'providerName' => "yahoy!", 'email' => "mymailprofile", 'preferredUsername' => "Chuck Norris"}
    flexmock(SocialService.instance).should_receive(:get_profile_info).with(:token).and_return(profile_template)
    flexmock(SocialService.instance).should_receive(:map).with(String, Integer).and_return(nil)
    flexmock(SocialService.instance).should_receive(:unmap).with(String, Integer).and_return(nil)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create new user given email" do
    assert_difference('User.count', 1) do
      post :create, :user => {:email => "nunchuck@gmail.com"}
      assert_response :redirect
    end
  end

  test "should fail to create new user without email" do
    assert_difference('User.count', 0) do
      post :create, :user => {}
      assert_response :redirect
    end
  end
  
  test "should create new user given social account" do
    assert_difference('User.count', 1) do
      post :create_social, :token => :token
      assert_response :redirect
    end
  end
  
  test "should change users email" do
    login_as :user
    assert_difference('PendingAction.count', 1) do
      put :update_email, :user => {:email => 'jokini@gmail.com', :email_confirmation => 'jokini@gmail.com'}
      assert_response :redirect
    end
  end
  
  test "should fail to change users email" do
    login_as :user
    assert_difference('User.count', 0) do
      put :update_email, :user => {:email => 'jokini@gmail.com', :email_confirmation => ''}
      assert_response :redirect
    end
  end

  test "should change users password" do
    login_as :user
    put :update_password, :old_password => 'true', :user => {:password => 'mega', :password_confirmation => 'mega'}
    assert_response :redirect
    u = User.find_by_email('user@echologic.org')
    assert u.has_password? 'mega'
  end
  
  test "should fail to change users password because old password is wrong" do
    login_as :user
    put :update_password, :old_password => 'pass', :user => {:password => 'mega', :password_confirmation => 'mega'}
    assert_response :redirect
    u = User.find_by_email('user@echologic.org')
    assert !u.has_password?('mega')
    assert u.has_password?('true')
  end
  
  test "should fail to change users password because there is no confirmation" do
    login_as :user
    put :update_password, :old_password => 'true', :user => {:password => 'mega'}
    assert_response :redirect
    u = User.find_by_email('user@echologic.org')
    assert u.has_password? 'mega'
  end

  test "should delete own account" do
    login_as :user
    put :destroy_account
    assert_response :redirect
    u = User.find_by_email('user@echologic.org')
    assert_nil u
  end
  
  test "should add social account" do
    login_as :user
    assert_difference('SocialIdentifier.count', 1) do
      put :add_social, :token => :token
      assert_response :redirect
    end
  end
  
  test "should remove social account" do
    login_as :joe
    assert_difference('SocialIdentifier.count', -1) do
      put :remove_social, :provider => 'facebook'
      assert_response :redirect
    end
  end

  test "should load setup basic profile form for a new user" do
    u = flexmock(User.create(:profile => Profile.new, :social_identifiers => [
                 SocialIdentifier.new(:identifier => "mi", :provider_name => "o2", 
                :profile_info => {:email => "main@main.com", :preferredUsername => "echo beach"}.to_json)]))
    put :setup_basic_profile, :activation_code => u.perishable_token
    assert_response :success
  end

  test "should get edit" do
   login_as :admin
   get :edit, :id => users(:user).to_param
   assert_response :success
  end
  
end
