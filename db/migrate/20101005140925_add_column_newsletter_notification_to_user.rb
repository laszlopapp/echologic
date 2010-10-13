class AddColumnNewsletterNotificationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :newsletter_notification, :integer, :default => 0
  end

  def self.down
    remove_column :users, :newsletter_notification
  end
end
