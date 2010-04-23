class RemoveShowProfileFromProfile < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :show_profile
  end

  def self.down
    add_column :profiles, :show_profile, :integer
  end
end
