namespace :activity_tracking do
  task :reset => :environment do
    Delayed::Job.destroy_all "handler LIKE '%#{ActivityTrackingJob.name}%'"
    ActivityTrackingService.instance.enqueue_activity_tracking_job
  end
end