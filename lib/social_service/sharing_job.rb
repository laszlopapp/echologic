class SharingJob < Thread
  
  attr_accessor :provider 
  
  def initialize(identifier, provider, activity)
    @provider = provider
    @success = SocialService.instance.share_activity(identifier, activity)
  end
  
  def succeeded?
    @success
  end
  
end