#
# This allows us to set up custom routes that depend on the domain or host of the request, ie:
# map.connect '', :controller => 'blah', :action => 'blah', :conditions => {:domain => 'blah'}
#
 
module ActionController
  module Routing
    class RouteSet
      def extract_request_environment(request)
        env = { :method => request.method }
        env[:domain] = request.domain if request.domain
        env[:host] = request.host if request.host    
        env[:port] = request.port if request.port  
        env[:rails_env] = RAILS_ENV
        env
      end
    end
    class Route
      alias_method :old_recognition_conditions, :recognition_conditions
      def recognition_conditions
        result = old_recognition_conditions
        result << "conditions[:domain] === env[:domain]" if conditions[:domain]
        result << "conditions[:host] === env[:host]" if conditions[:host]     
        result << "conditions[:port] === env[:port]" if conditions[:port]     
        result << "conditions[:rails_env] === RAILS_ENV" if conditions[:rails_env]   
        result
      end
    end
  end

end
