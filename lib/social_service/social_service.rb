require 'singleton'

  
class SocialService
  include Singleton
  
  attr_accessor :service
  
  def initialize
  end
  
  
  def get_user(token)
    profile_info = get_profile_info(token)
    return nil if profile_info.blank?
    identifier = profile_info['identifier']
    user = User.find_by_social_identifier(identifier)
    return user
  end
  def get_profile_info(token)
    @service.get_profile_info(token)
  end
  def mappings(primary_key)
    @service.mappings(primary_key)
  end
  def map(identifier, key)
    @service.map(identifier, key)
  end
  def unmap(identifier, key)
    @service.unmap(identifier, key)
  end
end

