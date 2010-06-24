class MailerTest < ActionMailer::TestCase 
#  def test_activity_tracking_email 
#    user = users(:user)  
#    # Send the email, then test that it got queued  
#    email = Mailer.deliver_activity_tracking_email!(user)  
#    assert !ActionMailer::Base.deliveries.empty? 
#    # Test the body of the sent email contains what we expect it to  
#    assert_equal [user.email], email.to 
#    assert_equal "Activity Tracking", email.subject 
##    assert_match /<h1>Welcome to example.com, #{user.name}<\/h1>/, email.encoded  
##    assert_match /Welcome to example.com, #{user.name}/, email.encoded  
#  end 
end 