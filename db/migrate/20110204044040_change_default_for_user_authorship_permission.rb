class ChangeDefaultForUserAuthorshipPermission < ActiveRecord::Migration
  def self.up
    change_column_default :users, :authorship_permission, 1
  end

  def self.down
    change_column_default :users, :authorship_permission, 0
  end
end
