require 'activity_tracking_service/acts_as_subscribeable'
require 'activity_tracking_service/event'
require 'activity_tracking_service/subscription'
require 'activity_tracking_service/activity_tracking_job'
require 'activity_tracking_service/activity_tracking_service'

if !RAILS_ENV.eql? 'production'
  ActivityTrackingService.instance.charges = 1
  ActivityTrackingService.instance.period = 30.minutes
else
  ActivityTrackingService.instance.charges = 7
  ActivityTrackingService.instance.period = 1.week
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Subscribeable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Subscriber

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
