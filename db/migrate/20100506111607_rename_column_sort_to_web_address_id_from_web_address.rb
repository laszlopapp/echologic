class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
#    rename_column :web_addresses, :location, :address
#    add_column :web_addresses, :web_address_type_id, :integer
    WebAddress.all.each do |old_web_address|
      new_web_address =WebAddress.new
      new_web_address.user_id = old_web_address.user_id
      new_web_address.address = old_web_address.address
      key = (old_web_address.sort == 99 ? old_web_address.sort : old_web_address.sort + 1)
      puts key.to_s
      new_web_address.web_address_type = EnumKey.find_by_key_and_enum_name(key, "web_address_types")
      
      puts new_web_address.web_address_type.code
      puts new_web_address.address
      
      new_web_address.save(false)
      
      old_web_address.destroy
    end
    #remove_column :web_addresses, :sort
#    rename_column :web_addresses, :sort, :web_address_type_id
    
  end

  def self.down
    rename_column :web_addresses, :address, :location
    rename_column :web_addresses, :web_address_type_id, :sort
  end
end
