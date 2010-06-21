class ActivityTrackingNotification
  attr_accessor :user_id
  def initialize(user_id)
    self.user_id = user_id
  end

  def perform
    Delayed::Job.enqueue(self.class.new(self.user_id),0,7.days.from_now)
    User.find(self.user_id).deliver_activity_tracking_email!
  end
end
