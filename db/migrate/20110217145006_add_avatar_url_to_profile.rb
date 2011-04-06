class AddAvatarUrlToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :avatar_remote_url, :string
  end

  def self.down
    remove_column :profiles, :avatar_remote_url
  end
end
