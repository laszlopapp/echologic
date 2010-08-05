require 'activity_notification_service/acts_as_subscribeable'
require 'activity_notification_service/event'
require 'activity_notification_service/subscription'


ActiveRecord::Base.send :include, ActiveRecord::Acts::Subscribeable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Subscriber