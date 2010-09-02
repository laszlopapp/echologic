class RenameColumnEmailNotificationInUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :email_notification, :activity_notification
  end

  def self.down
    rename_column :users, :activity_notification, :email_notification
  end
end
