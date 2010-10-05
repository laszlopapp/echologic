class AdminMailer < ActionMailer::Base
  # Send a feedback object as email to the FEEDBACK_RECIPIENT specified
  # in the environment.
  def newsletter(user, subject, text)  
    default = user.default_language
    subject       subject
    recipients    user.email
    from          "newsletter@echologic.org"
    sent_on       Time.now
    content_type  "text/html"
    body          :name => user.full_name, :text => text, :language => default
  end
end
