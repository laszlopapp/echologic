class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
    add_column :web_addresses, :web_address_type_id, :integer
    WebAddress.all.each do |web_address|
      key = web_address.sort
      key += 1 unless key == 99
      puts "former #{key}"
      web_address.update_attribute("web_address_type_id", EnumKey.find_by_key_and_name(key, "web_address_types").id)
    end
    #remove_column :web_addresses, :sort
#    rename_column :web_addresses, :sort, :web_address_type_id
    
  end

  def self.down
    rename_column :web_addresses, :web_address_type_id, :sort
  end
end
