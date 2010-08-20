class RenameColumnEmailNotificationInUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :email_notification, :activity_notification
    change_column :users, :activity_notification, :default => 1
    User.all.each do |user|
      user.activity_notification = 0
      user.save
    end
  end

  def self.down
    rename_column :users, :activity_notification, :email_notification
  end
end
