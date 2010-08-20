class ChangeColumnActivityNotificationInUser < ActiveRecord::Migration
  def self.up
    change_column_default :users, :activity_notification, 1
    User.all.each do |user|
      user.activity_notification = 0
      user.save
    end
  end

  def self.down
  end
end
