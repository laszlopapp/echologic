class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
    rename_column :web_addresses, :location, :address
    add_column :web_addresses, :web_address_type_id, :integer
    
  end

  def self.down
    rename_column :web_addresses, :address, :location
    remove_column :web_addresses, :web_address_type_id
  end
end
