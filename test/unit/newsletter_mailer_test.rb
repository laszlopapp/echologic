require 'test_helper'

class NewsletterMailerTest < ActiveSupport::TestCase
  
  # Test newsletter by mother tongue with mother tongue being default
  def test_newsletter
    user = users(:user)
    newsletter = Newsletter.create(:subject => "I have a dream", :text => "I forgot")
    # Send the email, then test that it got queued
    email = NewsletterMailer.deliver_newsletter_mail!(user,newsletter)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "I have a dream", email.subject
    assert_match /Dear User Test/, email.encoded
    assert_match /I forgot/, email.encoded
    assert_match /Best Regards/, email.encoded
  end
  
  # Test newsletter by default
  def test_newsletter
    user = users(:ben)
    newsletter = Newsletter.create(:subject => "I have a dream", :text => "I forgot")
    # Send the email, then test that it got queued
    email = NewsletterMailer.deliver_newsletter_mail!(user,newsletter)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "I have a dream", email.subject
    assert_match /Dear User Test/, email.encoded
    assert_match /I forgot/, email.encoded
    assert_match /Best Regards/, email.encoded
  end
  
  # Test newsletter by mother tongue
  def test_newsletter
    user = users(:ben)
    newsletter = Newsletter.create(:subject => "I have a dream", :text => "I forgot")
    I18n.locale = 'de'
    newsletter.subject = "Ich habe einen Traum"
    newsletter.text = "Ich hab's vergessen"
    newsletter.save
    # Send the email, then test that it got queued
    email = NewsletterMailer.deliver_newsletter_mail!(user,newsletter)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "Ich habe einen Traum", email.subject
    assert_match /Hallo Ben Test/, email.encoded
    assert_match /Ich hab's vergessen/, email.encoded
    assert_match /Herzliche Grüße/, email.encoded
  end
end
