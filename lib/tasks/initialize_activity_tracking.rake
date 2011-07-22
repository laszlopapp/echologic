namespace :activity_tracking do
  task :initialize => :environment do
    ActivityTrackingService.instance.enqueue_activity_tracking_job
  end
  
  desc "Sends an activity tracking mail to the first user or the email it is given"
  task :send_activity_tracking_mail => :environment do
    email = ENV["email"]
    if email
      user = User.first
      old_email = user.email
      user.email = email
      user.save
    end  
    
    events = Event.all.map{|e| JSON.parse(e.event)}
    
    root_events, events, question_tag_counts = ActivityTrackingService.instance.build_events_hash(events)
    
    ActivityTrackingService.instance.send_activity_mail(user, root_events, question_tag_counts, events)
    
    if email 
      user.email = old_email
      user.save
    end
  end
end