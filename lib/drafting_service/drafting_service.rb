require 'singleton'

class DraftingService
  
  include Singleton

  def update(*args)
    send(*args)
  end

  def after_supported(echoable)
    puts "#{echoable.class.name} supported"
  end
  
  def after_unsupported(echoable)
    puts "#{echoable.class.name} unsupported"
  end
  
  def after_create(echoable)
    puts "#{echoable.class.name} created"
  end
end