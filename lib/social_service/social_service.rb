require 'singleton'
  
class SocialService
  include Singleton
  
  attr_accessor :service, :social_providers
  
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
    with_indifferent_access(data)
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
  def get_provider_signup_url(provider, token_url)
    @service.get_provider_signup_url(provider, token_url)
  end
  def load_basic_profile_options(profile_info)
    {:email => profile_info['verifiedEmail']||profile_info['email'], 
     :full_name => profile_info['preferredUsername']||profile_info['displayName']}
 end
 
 private
  def with_indifferent_access(hash)
    hash.respond_to?(:with_indifferent_access) ? hash.with_indifferent_access : hash
  end
end

