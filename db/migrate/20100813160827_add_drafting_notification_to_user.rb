class AddDraftingNotificationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :drafting_notification, :integer, :default => 1
    User.all.each do |user|
      user.drafting_notification = 0
      user.save
    end
  end

  def self.down
    remove_column :users, :drafting_notification
  end
end
