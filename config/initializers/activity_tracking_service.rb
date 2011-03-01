require 'activity_tracking_service/acts_as_subscribeable'
require 'activity_tracking_service/event'
require 'activity_tracking_service/subscription'
require 'activity_tracking_service/activity_tracking_job'
require 'activity_tracking_service/activity_tracking_service'
require 'echo_service/echo_service'

if !RAILS_ENV.eql? 'production'
  ActivityTrackingService.instance.charges = 3
  ActivityTrackingService.instance.period = 15.minutes
else
  ActivityTrackingService.instance.charges = 24
  ActivityTrackingService.instance.period = 1.day
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Subscribeable
ActiveRecord::Base.send :include, ActiveRecord::Acts::Subscriber

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 15.minutes

# Observers
EchoService.instance.add_observer(ActivityTrackingService.instance)