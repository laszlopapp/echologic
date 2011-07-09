require 'routing_filter/base'

module RoutingFilter
  class Mode < Base
    cattr_writer :current_mode
    class << self
      def modes
        @@modes ||= [:embed]
      end
  
      def modes_pattern
        @@modes_pattern ||= %r(^/(#{self.modes.map { |l| Regexp.escape(l.to_s) }.join('|')})(?=/|$))
      end
    end
    
    def current_mode
      @@current_mode
    end
    
    def around_recognize(path, env, &block)
      mode = extract_mode!(path) 
      returning yield do |params|
        params[:mode] = mode
      end
    end

    def around_generate(*args, &block)
      mode = args.extract_options!.delete(:mode) || current_mode
      returning yield do |result|
        url = result.is_a?(Array) ? result.first : result
        prepend_mode(url, mode) if prepend_mode?(url, mode)
      end
    end
    
    protected

    def extract_mode!(path)
      path.sub! self.class.modes_pattern, ''
      $1
    end
    
    def prepend_mode?(url, mode)
      mode and !url[/(http.?:\/\/(\\w{2}\/)?)?#{mode}/]
    end
    
    def prepend_mode(url, mode)
      url.sub!(%r(^(http.?://[^/]*)?(/\w{2}/)?(.*))) { "#{$1}#{$2}/#{mode}#{$3}" }
    end
    
  end
end
