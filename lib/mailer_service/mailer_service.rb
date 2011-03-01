require 'singleton'

class MailerService
  include Singleton


  # Sends newsletters to all subscribers.
  def send_newsletter_mails(newsletter)
    User.newsletter_recipients.each do |recipient|
      NewsletterMailer.deliver_newsletter_mail(recipient, newsletter)
      puts "Newsletter has been delivered to: " + recipient.email
      sleep 2
    end
  end

  ###############
  # Async calls #
  ###############

  handle_asynchronously :send_newsletter_mails

end