class AddShowProfileToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :show_profile, :integer
  end

  def self.down
    remove_column :profiles, :show_profile
  end
end
