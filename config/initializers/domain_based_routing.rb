module ActionController
  module Routing
    class RouteSet
      def extract_request_environment(request)
        env = { :method => request.method }
        env[:domain] = request.domain if request.domain
        env[:host] = request.host if request.host          
        env
      end
    end
    class Route
      alias_method :old_recognition_conditions, :recognition_conditions
      def recognition_conditions
        result = old_recognition_conditions
        result << "conditions[:domain] === env[:domain]" if conditions[:domain]
        result << "conditions[:host] === env[:host]" if conditions[:host]        
        result
      end
    end
  end
end
