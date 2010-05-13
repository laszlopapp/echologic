class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
    rename_column :web_addresses, :sort, :web_address_type_id 
    
    WebAddress.all.each do |web_address|
      web_address.web_address_type_id = EnumKey.find_by_key_and_name(web_address.web_address_type_id+1,"web_addresses").id
      web_address.save
    end
  end

  def self.down
    rename_column :web_addresses, :web_address_type_id, :sort
  end
end
