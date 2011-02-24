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
    opts= {:email => profile_info['email'], :first_name => profile_info['preferredUsername'],
           :social_identifiers => [SocialIdentifier.new(:identifier => profile_info['identifier'], 
                                                        :provider_name => profile_info['providerName'],
                                                        :profile_info => profile_info.to_json )]}
    opts
  end
end

