require 'acts_as_extaggable'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Extaggable
