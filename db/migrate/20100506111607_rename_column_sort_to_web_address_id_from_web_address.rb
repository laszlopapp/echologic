class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
    add_column :web_addresses, :web_address_type_id, :integer    
    WebAddress.all.each do |web_address|
      puts web_address.web_address_type_id.to_s
      puts web_address.sort.to_s
      puts EnumKey.find_by_key_and_name(web_address.sort.to_i + 1, "web_addresses").inspect
      web_address.web_address_type_id = EnumKey.find_by_key_and_name(web_address.sort.to_i+1,"web_addresses").id
      
      web_address.save
    end
    remove_column :web_addresses, :sort
  end

  def self.down
    rename_column :web_addresses, :web_address_type_id, :sort
  end
end
