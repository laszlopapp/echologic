require 'drafting_service/drafting_service'
require 'drafting_service/acts_as_incorporable'
require 'drafting_service/acts_as_drafteable'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Incorporable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Drafteable

