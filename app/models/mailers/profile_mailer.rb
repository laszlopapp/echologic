class ProfileMailer < ActionMailer::Base
  
  # Send a user email communication between two echo users
  def user_mail(sender, recipient, mail)
    subject       "[echo message] #{mail[:subject]}"
    from          "noreply@echologic.org"
    recipients    [recipient.email]
    reply_to      [sender.email]
    sent_on       Time.now
    body          :sender => sender, :text => mail[:text]
  end
end