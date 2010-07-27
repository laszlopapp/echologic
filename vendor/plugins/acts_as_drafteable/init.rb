require 'acts_as_drafteable'
require 'acts_as_drafter'

ActiveRecord::Base.send :include, Drafteable
ActiveRecord::Base.send :include, Drafter