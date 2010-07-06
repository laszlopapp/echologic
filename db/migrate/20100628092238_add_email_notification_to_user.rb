class AddEmailNotificationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :email_notification, :integer
  end

  def self.down
    remove_column :users, :email_notification
  end
end
