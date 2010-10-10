namespace :activity_tracking do
  task :initialize => :environment do
    ActivityTrackingService.instance.enqueue_activity_tracking_job
  end
end