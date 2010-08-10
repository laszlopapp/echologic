require 'activity_notification_service/acts_as_subscribeable'
require 'activity_notification_service/event'
require 'activity_notification_service/subscription'
require 'activity_notification_service/activity_tracking_notification'
require 'activity_notification_service/activity_notification_service'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Subscribeable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Subscriber

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
