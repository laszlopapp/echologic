require "compatibility/active_record_backports" if ActiveRecord::VERSION::MAJOR < 3

require 'acts_as_extaggable'
require 'acts_as_taggable/core'
require "tag_list"

ActiveRecord::Base.send :include, ActiveRecord::Acts::Extaggable
ActiveRecord::Base.extend ActsAsTaggable::Taggable