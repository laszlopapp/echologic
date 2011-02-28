require 'test_helper'

class ActivationsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    @controller = Users::ActivationsController.new
  end
  
  test "should get new" do
    get :new
    assert_response :redirect
  end
  
  test "should activate coming from the activation form" do
    u = flexmock(User.new)
    u.create_profile
    u.signup!({:email => "mymummysdead@john.com"})
    post :create, :activation_code => u.perishable_token, :user => {:full_name => "Mad Max", :password => "pass", :password_confirmation => "pass"}
    u.reload
    assert u.active?
    assert u.has_password?("pass")
  end
  
  test "should activate coming from the setup basic profile form with an unverified email" do
    u = flexmock(User.create(:profile => Profile.new, :social_identifiers => [
                 SocialIdentifier.new(:identifier => "mi", :provider_name => "o2", 
                :profile_info => {'email' => "main@main.com", 'preferredUsername' => "echo beach"}.to_json)]))
    assert_difference('ActionMailer::Base.deliveries.count', 1) do # activate email
      post :create, :activation_code => u.perishable_token, :user => {:full_name => "Mad Max", :email => "main@main.com"}
      u.reload
      assert !u.active?
      assert u.email.eql?("main@main.com")
    end
  end
  
  test "should activate coming from the setup basic profile form with a verified email" do
    u = flexmock(User.new(:profile => Profile.new, :social_identifiers => [
                 SocialIdentifier.new(:identifier => "mi", :provider_name => "o2", 
                :profile_info => {'verifiedEmail' => "main@main.com", 'preferredUsername'=> "echo beach"}.to_json)]))
    u.save
    assert_difference('ActionMailer::Base.deliveries.count', 1) do #activation confirmation email
      post :create, :activation_code => u.perishable_token, :user => {:full_name => "Mad Max", :email => "main@main.com"}
      u.reload
      assert u.active?
    end
  end
end
