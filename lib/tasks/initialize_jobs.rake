namespace :jobs do
  desc "move all Web Address sorts to type_ids"
  task :initialize => :environment do
    # Deletes old delayed Jobs and starts a new one for the activity tracking email sending
    Delayed::Job.destroy_all
    ActivityNotificationService.instance.enqueue_activity_tracking_email
  end
end