require 'acts_as_drafteable'
require 'acts_as_drafter'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Drafteable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Drafter