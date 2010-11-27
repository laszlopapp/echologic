class NewsletterMailer < ActionMailer::Base
  #default_url_options[:host] = ECHO_HOST

  # Send a newletter to the given user.
  def newsletter(recipient, subject, text)
    language = recipient.default_language
    subject       subject
    recipients    recipient.email
    from          "newsletter@echologic.org"
    sent_on       Time.now
    content_type  "text/html"
    body          :name => recipient.full_name, :text => text, :language => language
  end
end
