module CasHelper
  def cas_login_token
    base_uri = URI.parse(CASClient::Frameworks::Rails::Filter.config[:cas_base_url])
    use_ssl = (base_uri.scheme == 'https' ? true : false)
    http = Net::HTTP.new(base_uri.host, base_uri.port)
    http.use_ssl = use_ssl
    req = Net::HTTP::Post.new('/loginTicket')
    # nginx fails with 411 if POST requests have no Content-Length set
    # (i.e. http://www.ruby-forum.com/topic/162976)
    req['Content-Length'] = 0
    return http.request(req).body
  end
end
