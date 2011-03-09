class SharingJob < Thread
  
  attr_accessor :provider 
  
  def initialize(identifier, provider, activity)
    super {
      @provider = provider
      puts "Sharing... #{provider}"
      @success = SocialService.instance.share_activity(identifier, activity)
      puts "Ending #{provider}"
      Thread.pass
    }
  end
  
  def succeeded?
    @success
  end
  
end