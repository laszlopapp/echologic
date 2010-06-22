class ActivityTrackingNotification
  
  def initialize
  end

  def perform
    week_day = Time.now.wday
    User.all(:conditions => ["(id % 7) = ?", week_day]).each do |user|
      user.deliver_activity_tracking_email!
    end
    Delayed::Job.enqueue ActivityTrackingNotification.new, 0, Time.now.tomorrow.midnight
  end
end
