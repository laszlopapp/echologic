namespace :jobs do
  task :initialize => :environment do
    # Deletes old delayed Jobs and starts a new one for the activity tracking email sending
    Delayed::Job.destroy_all "handler LIKE '%#{ActivityTrackingJob.name}%'"
    ActivityTrackingService.instance.enqueue_next_activity_tracking_job
  end
end