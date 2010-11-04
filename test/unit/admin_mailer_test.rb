require 'test_helper'

class AdminMailerTest < ActiveSupport::TestCase
  def test_newsletter
    user = users(:user)
    subject = "This is a Test Subject"
    text = "This is a Test Text"
    # Send the email, then test that it got queued
    email = AdminMailer.deliver_newsletter!(user,subject,text)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal subject, email.subject
    assert_match /Dear #{user.full_name}/, email.encoded
  end
end
