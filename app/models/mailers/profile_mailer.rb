class ProfileMailer < ActionMailer::Base

  # Send a user email communication between two echo users
  def user_mail(sender, recipient, mail)
    language = recipient.default_language
    subject       I18n.t("mailers.user_mail.subject",
                         :subject => mail[:subject])
    from          "user@echo.to"
    recipients    [recipient.email]
    reply_to      [sender.email]
    sent_on       Time.now
    body          :sender => sender,
                  :recipient => recipient,
                  :text => mail[:text],
                  :language => language
  end
end