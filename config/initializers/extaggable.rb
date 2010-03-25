require 'acts-as-taggable-on'

ActiveRecord::Base.send :include, ActiveRecord::Acts::TaggableOn
ActionView::Base.send :include, TagsHelper if defined?(ActionView::Base)
