class FeedbackMailer < ActionMailer::Base

  # Send a feedback object as email to the FEEDBACK_RECIPIENT specified
  # in the environment.
  def feedback(feedback)
    subject       "echo - Feedback from #{feedback.name}"
    recipients    FEEDBACK_RECIPIENT
    from          "feedback@echo.to"
    reply_to      [feedback.email, FEEDBACK_RECIPIENT]
    sent_on       Time.now
    body          :name => feedback.name, :message => feedback.message
  end

end