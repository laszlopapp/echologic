class AddEmailNotificationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :email_notification, :integer
    User.all.each do |user|
      user.email_notification = 0
      user.save
    end
  end

  def self.down
    remove_column :users, :email_notification
  end
end
