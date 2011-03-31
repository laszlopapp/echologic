require 'singleton'

class SocialService
  include Singleton

  attr_accessor :service, :social_providers, :default_echo_image

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

  def all_mappings(primary_key)
    @service.all_mappings(primary_key)
  end

  def share_activities(providers, opts={})
    providers_status = {:success => [], :failed => [], :timeout => []}
    threads = []
    providers.each do |provider, social_identifier|
      activity = create_activity(provider, opts)
      threads << SharingJob.new(social_identifier.identifier, provider, activity)
    end
    threads.each do |t|
      t.join(10)
    end
    threads.each do |t|
      if t.terminated? 
       providers_status[t.succeeded? ? :success : :failed] << t.provider
      else
        providers_status[:timeout] << t.provider
      end
    end
    providers_status
  end


  def share_activity(identifier, activity)
    begin
      @service.activity(identifier, activity)
    rescue Exception => e
      puts "Something went wrong with #{identifier}"
      false
    else
      puts "Successfully shared to #{identifier}"
      true
    end
  end


  def get_provider_signup_url(provider, token_url)
    @service.get_provider_signup_url(provider, token_url)
  end


  def load_basic_profile_options(profile_info)
    {:email => profile_info['verifiedEmail'] || profile_info['email'],
     :full_name => profile_info['displayName'] || profile_info['preferredUsername']}
  end


  private
  def create_activity(providerName, attrs={})
    opts = attrs.clone

    # Handling images
    opts[:media] ||= []
    images = opts.delete(:images) || []
    images.each do |image|
      opts[:media] << {:href => opts[:url], :src => image, :type => 'image'}
    end
    # Adding default echo image
    opts[:media] << {:href => opts[:url], :src => "http://#{ECHO_HOST}/#{@default_echo_image}", :type => 'image'}

    # Handling actions
    action_links = opts.delete(:action_links) || []
    action_links.each do |al|
      opts[:action_links] ||= []
      opts[:action_links] << {:text => al, :href => opts[:url]}
    end

    opts[:action] += " #{opts[:url]}" if !providerName.eql?('twitter')
    opts[:user_generated_content] = opts[:action]

    opts[:action] = "made an echo" if providerName.eql?('facebook')

    #TAG TEST
    opts[:url] += " #test" if providerName.eql?('twitter')
    opts.to_json
  end
end

