#
# Ruby Helper Class for Janrain Engage
#
require 'uri'
require 'net/http'
require 'net/https'
require 'json'


class RpxService
  attr_reader :api_key, :base_url, :realm
  
  def initialize(api_key, base_url, realm)
    @api_key = api_key
    @base_url = base_url.sub(/\/*$/, '')
    @realm = realm
  end
  def get_profile_info(token)
    data = api_call 'auth_info', :token => token
    data['profile']
  end
  def get_user_data(identifier)
    data = api_call 'get_user_data', :identifier => identifier
    data['profile']
  end
  def mappings(primary_key)
    data = api_call 'mappings', :primaryKey => primary_key
    data['identifiers']
  end
  def map(identifier, key)
    api_call 'map', :primaryKey => key, :identifier => identifier
  end
  def unmap(identifier, key)
    api_call 'unmap', :primaryKey => key, :identifier => identifier
  end
  def signin_url(dest)
    "#{rp_url}/openid/signin?token_url=#{CGI.escape(dest)}"
  end
  def get_provider_signup_url(provider, token_url)
    url = CGI::escape(token_url)
    case provider
      when "facebook" then "https://#{RPX_APP_NAME}/facebook/connect_start?token_url=#{url}&ext_perm=publish_stream,email,offline_access"
      when "twitter" then "https://#{RPX_APP_NAME}/twitter/start?token_url=#{url}"
      when "yahoo" then "https://#{RPX_APP_NAME}/openid/start?openid_identifier=http://me.yahoo.com/&token_url=#{url}"
      when "linked_in" then "https://#{RPX_APP_NAME}/linkedin/start?token_url=#{url}"
      when "google" then "https://#{RPX_APP_NAME}/openid/start?openid_identifier=https://www.google.com/accounts/o8/id&token_url=#{url}"
    end
  end
  private
  def rp_url
    parts = @base_url.split('://', 2)
    parts = parts.insert(1, '://' + @realm + '.')
    parts.join
  end
  def api_call(method_name, partial_query)
    url = URI.parse("#{@base_url}/api/v2/#{method_name}")
    query = partial_query.dup
    query['format'] = 'json'
    query['apiKey'] = @api_key
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == 'https'
      http.use_ssl = true
    end
    data = query.map { |k,v|
      "#{CGI::escape k.to_s}=#{CGI::escape v.to_s}"
    }.join('&')
    resp = http.post(url.path, data)
    if resp.code == '200'
      begin
        data = JSON.parse(resp.body)
      rescue JSON::ParserError => err
        raise RpxException.new(resp), 'Unable to parse JSON response'
      end
    else
      raise RpxException.new(resp), "Unexpected HTTP status code from server: #{resp.code}"
    end
    if data['stat'] != 'ok'
      raise RpxException.new(resp), 'Unexpected API error'
    end
    data
  end
  
  
  
  class RpxException < StandardError
    attr_reader :http_response
    def initialize(http_response)
      @http_response = http_response
    end
  end
end

