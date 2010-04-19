require 'test_helper'
require 'net/smtp'

class FeedbackControllerTest < ActionController::TestCase
  def setup    
    @controller = FeedbackController.new
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should fail to create feedback" do
    assert_difference('Feedback.count', 0) do
      post :create, :feedback => {:name => nil , :email => "joedoe@joesworld.com" , :message => "I got blisters on my fingers!"}
      post :create, :feedback => {:name => "Joe" , :email => "joedoe@joesworld.com" , :message => nil}
    end
  end

  test "should create feedback" do
    assert_no_emails
    assert_difference('Feedback.count') do
      post :create, :feedback => {:name => "Joe" , :email => "joedoe@joesworld.com" , :message => "I got blisters on my fingers!"}
    end
    assert_emails 1
  end
  
  
end
