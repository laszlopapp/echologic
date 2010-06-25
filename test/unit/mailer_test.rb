require 'test_helper'

class MailerTest < ActionMailer::TestCase 
  def test_activity_tracking_email 
    user = users(:user)  
    question_events = [events(:event_test_question)]
    tags = {'#echonomyjam' => 1}
    events = []
    # Send the email, then test that it got queued  
    email = Mailer.deliver_activity_tracking_email!(user,question_events,tags,events)  
    assert !ActionMailer::Base.deliveries.empty? 
    # Test the body of the sent email contains what we expect it to  
    assert_equal [user.email], email.to 
    assert_equal "Activity Tracking", email.subject 
#    assert_match /<h1>Welcome to example.com, #{user.name}<\/h1>/, email.encoded  
#    assert_match /Welcome to example.com, #{user.name}/, email.encoded  
  end 
end 