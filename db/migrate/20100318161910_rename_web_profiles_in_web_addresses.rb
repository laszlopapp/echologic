class RenameWebProfilesInWebAddresses < ActiveRecord::Migration
  def self.up
    rename_table :web_profiles, :web_addresses
  end

  def self.down
    rename_table :web_addresses, :web_profiles
  end
end
