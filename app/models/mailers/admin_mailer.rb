class AdminMailer < ActionMailer::Base

  # Send a newletter to the given user.
  def newsletter(user, subject, text)
    language = user.default_language
    subject       subject
    recipients    user.email
    from          "newsletter@echologic.org"
    sent_on       Time.now
    content_type  "text/html"
    body          :name => user.full_name, :text => text, :language => language
  end
end
