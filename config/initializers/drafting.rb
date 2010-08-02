require 'drafting_service/drafting_service'
require 'drafting_service/acts_as_incorporable'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Incorporable

