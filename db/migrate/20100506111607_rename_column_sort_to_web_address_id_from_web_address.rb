class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
    rename_column :web_addresses, :sort, :web_address_id 
  end

  def self.down
    rename_column :web_addresses, :web_address_id, :sort
  end
end
