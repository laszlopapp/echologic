class RenameTableEchoDetailsToUserEchos < ActiveRecord::Migration
  def self.up
    rename_table :echo_details, :user_echos
  end

  def self.down
    rename_table :user_echos, :echo_details
  end
end
