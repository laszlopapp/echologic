require 'singleton'


class ActivityNotificationService
  include Singleton
  
  def update(*args)
    send(*args)
  end

  def supported(echoable, user)
    echoable.add_subscriber(user)
  end
  
  def unsupported(echoable, user)
    echoable.remove_subscriber(user)
  end
  
  def incorporated(echoable)
    echoable.parent.supporters.select{|sup|sup.languages('advanced').include?(statement.original_language)}.each do |supporter|
      email = ActivityTrackingMailer.create_incorporation_notification(statement, statement_document, supporter)
      ActivityTrackingMailer.deliver(email)
    end
  end
end