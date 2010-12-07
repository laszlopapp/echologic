class NewsletterMailer < ActionMailer::Base
  layout 'mail'
  helper :mail

  # Send a newletter to the given user.
  def newsletter_mail(recipient, subject, text)
    language = recipient.default_language
    subject       subject
    recipients    recipient.email
    from          "noreply@echologic.org"
    sent_on       Time.now
    content_type  "text/html"
    body          :name => recipient.full_name,
                  :text => text,
                  :language => language
  end
end
