class AddDraftingNotificationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :drafting_notification, :integer, :default => 1
  end

  def self.down
    remove_column :users, :drafting_notification
  end
end
