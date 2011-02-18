require 'test_helper'

class NewslettersControllerTest < ActionController::TestCase
  def setup
    login_as :admin
    @controller = NewslettersController.new
    user = users(:user)
    user.update_attribute(:newsletter_notification, 1)
    @newsletter = newsletters(:first_newsletter)
  end
  
  test "should deliver test newsletter" do
    assert_difference('ActionMailer::Base.deliveries.length', 1) do
      post :test_newsletter, :id => @newsletter.to_param
    end
  end
  
  test "should deliver newsletter" do
    assert_difference('ActionMailer::Base.deliveries.length', User.count) do
      post :send_newsletter, :id => @newsletter.to_param
    end
  end
end
