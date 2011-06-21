require 'singleton'

class MailerService
  include Singleton

  #
  # Sends the newsletter with the given Id to all subscribers.
  #
  def send_newsletter_mails(newsletter_id)
    User.newsletter_recipients.map(&:id).each do |recipient_id|
      send_newsletter_mail(recipient_id, newsletter_id)
    end
  end

  #
  # Sends the given newsletter to the given user.
  # Executed async in production environment.
  #
  def send_newsletter_mail(recipient_id, newsletter_id)
    recipient = User.find(recipient_id)
    newsletter = Newsletter.find(newsletter_id)
    NewsletterMailer.deliver_newsletter_mail(recipient, newsletter)
    puts "Newsletter has been delivered to: " + recipient.email
    sleep 2
  end
  
  
  def send_user_mail(sender, recipient, mail)
    ProfileMailer.deliver_user_mail(sender, recipient, mail)
    puts "User #{sender.id} has sent an email to: " + recipient.email
    sleep 2
  end

  ###############
  # Async calls #
  ###############

  #handle_asynchronously :send_newsletter_mail

end