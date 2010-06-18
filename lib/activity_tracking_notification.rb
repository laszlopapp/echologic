class ActivityTrackingNotification
  attr_accessor :user_id
  def initialize(user_id)
    self.user_id = user_id
  end

  def perform
    User.find(self.user_id).deliver_activity_tracking_email!
  end
end
