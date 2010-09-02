class ChangeColumnActivityNotificationInUser < ActiveRecord::Migration
  def self.up
    change_column_default :users, :activity_notification, 1
  end

  def self.down
  end
end
