require 'acts_as_alternative'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Alternative
