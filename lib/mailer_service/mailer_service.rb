require 'singleton'

class MailerService
  include Singleton


  # Sends newsletters to all subscribers.
  def send_newsletter_mails(newsletter)
    User.find(:all, :conditions => {:newsletter_notification => 1}).each do |recipient|
      NewsletterMailer.deliver_newsletter_mail(recipient, newsletter)
#      puts "Newsletter has been delivered to: " + recipient.email
#      sleep 3
    end
  end

  ###############
  # Async calls #
  ###############

#  handle_asynchronously :send_newsletter_mails

end