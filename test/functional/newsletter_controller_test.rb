require 'test_helper'

class NewsletterControllerTest < ActionController::TestCase
  def setup    
    @controller = NewsletterController.new
    user = users(:user)
    user.update_attribute(:newsletter_notification, 1)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should fail to create newsletter" do
    assert_difference('ActionMailer::Base.deliveries.length', 0) do
      post :create, :newsletter => {:subject => '' , :text => "I got blisters on my fingers!"}
      post :create, :newsletter => {:subject => 'I got blisters on my fingers!' , :text => ''}
    end
  end

  test "should create newsletter" do
    assert_difference('ActionMailer::Base.deliveries.length', 1) do
      post :create, :newsletter => {:subject => 'Paul is dead' , :text => 'I got blisters on my fingers!'}
    end
  end
end
