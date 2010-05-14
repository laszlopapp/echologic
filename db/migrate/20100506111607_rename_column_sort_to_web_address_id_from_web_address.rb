class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
    rename_column :web_addresses, :location, :address
    add_column :web_addresses, :web_address_type_id, :integer
    WebAddress.all.each do |web_address|
      key = (web_address.sort == 99 ? web_address.sort : web_address.sort + 1)
      puts key.to_s
      web_address.web_address_type_id = EnumKey.find_by_key_and_enum_name(key, "web_address_types").id
      web_address.save(false)
    end
    
    #remove_column :web_addresses, :sort
#    rename_column :web_addresses, :sort, :web_address_type_id
    
  end

  def self.down
    rename_column :web_addresses, :address, :location
    rename_column :web_addresses, :web_address_type_id, :sort
  end
end
