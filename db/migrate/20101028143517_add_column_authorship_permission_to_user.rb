class AddColumnAuthorshipPermissionToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :authorship_permission, :integer, :default => 0
  end

  def self.down
    remove_column :users, :authorship_permission
  end
end
