class SharingJob < Thread
  
  attr_accessor :provider 
  
  def initialize(identifier, provider, activity)
    super {
      @provider = provider
      puts "Sharing... #{provider}"
      @success = SocialService.instance.share_activity(identifier, activity)
      @terminated = true
      puts "Ending #{provider}"
      Thread.pass
    }
  end
  
  def terminated?
    @terminated
  end
  
  def succeeded?
    @success
  end
  
end