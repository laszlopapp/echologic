class ChangeNewsletterNotificationDefault < ActiveRecord::Migration
  def self.up
    change_column_default :users, :newsletter_notification, 1
  end

  def self.down
    change_column_default :users, :newsletter_notification, 0
  end
end
