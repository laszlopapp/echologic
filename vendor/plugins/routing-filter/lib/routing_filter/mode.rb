require 'routing_filter/base'

module RoutingFilter
  class Mode < Base
    class << self
      
      def modes
        @@modes ||= [:embed]
      end
  
      def modes_pattern
        @@modes_pattern ||= %r(^/(#{self.modes.map { |l| Regexp.escape(l.to_s) }.join('|')})(?=/|$))
      end
    end
    
    def around_recognize(path, env, &block)
      mode = extract_mode!(path)   
      returning yield do |params|
        params[:mode] = mode
      end
    end

    def around_generate(*args, &block)
      puts args.inspect
      mode = args.extract_options!.delete(:mode) 
      puts mode.inspect
      returning yield do |result|
        if mode
          url = result.is_a?(Array) ? result.first : result
          prepend_mode(url, mode)
        end
      end
    end
    
    protected

    def extract_mode!(path)
      path.sub! self.class.modes_pattern, ''
      $1
    end
    
    def prepend_mode(url, mode)
      url.sub!(%r(^(http.?://[^/]*\/[^/]*)?(.*))) { "#{$1}/#{mode}#{$2}" }
    end
    
  end
end
