require 'test_helper'

class ProfileMailerTest < ActiveSupport::TestCase
  include ActionController::UrlWriter
  # Test newsletter by mother tongue with mother tongue being default
  def test_user_mail
    sender = users(:user)
    recipient = users(:joe)
    I18n.locale = "en"
    mail = {:subject => "This is the subject", :text => "This is the text"}
    # Send the email, then test that it got queued
    email = ProfileMailer.deliver_user_mail!(sender,recipient, mail)
    assert !ActionMailer::Base.deliveries.empty?
    # Test the body of the sent email contains what we expect it to
    assert_equal [recipient.email], email.to
    assert_equal I18n.t("mailers.user_mail.subject", :subject => mail[:subject]), email.subject
    assert_match /#{I18n.t("mailers.user_mail.prefix", :sender => sender.full_name)}/, email.encoded
    assert_match /#{mail[:text]}/, email.encoded
    assert email.encoded.include? I18n.t("mailers.user_mail.suffix", :url => connect_search_url(:id => sender.profile.id, 
                                                                                  :host => ECHO_HOST),
                                                                           :sender => sender.full_name)
  end
end
