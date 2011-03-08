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
  def get_user_data(identifier)
    @service.get_user_data(identifier)
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
  def activity(identifier, provider, opts={})
    activity_structure = create_activity_structure(provider, opts)
    @service.activity(identifier, activity_structure)
  end
  def get_provider_signup_url(provider, token_url)
    @service.get_provider_signup_url(provider, token_url)
  end
  def load_basic_profile_options(profile_info)
    {:email => profile_info['verifiedEmail']||profile_info['email'], 
     :full_name => profile_info['preferredUsername']||profile_info['displayName']}
  end
  private
  def create_activity_structure(providerName, opts={})
    images = opts.delete(:images) || []
    images.each do |im|
      opts[:media] ||= []
      opts[:media] << {:href => opts[:url], :src => im, :type => 'image'}
    end
    action_links = opts.delete(:action_links) || []
    action_links.each do |al|
      opts[:action_links] ||= []
      opts[:action_links] << {:text => al, :href => opts[:url]}
    end
    opts[:user_generated_content] = opts[:action]
    opts[:action] = "made an echo" if providerName.eql?('facebook')
    opts.to_json
  end
end

