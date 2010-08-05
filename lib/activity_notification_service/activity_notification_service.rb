require 'singleton'


class ActivityNotificationService
  include Singleton
  
  def update(*args)
    send(*args)
  end

  def after_supported(echoable, user)
    echoable.add_subscriber(user)
  end
  
  def after_unsupported(echoable, user)
    echoable.remove_subscriber(user)
  end
  
  def after_create(echoable, user)
    puts "#{echoable.class.name} created"
  end
end