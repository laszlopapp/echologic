class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
    add_column :web_addresses, :web_address_type_id, :integer
    WebAddress.all.each do |web_address|
      key = web_address.sort
      puts "former #{key}"
      key += 1 unless key == 99
      puts "Enum Key: #{EnumKey.find_by_key_and_name(key, "web_address_types").inspect}"
      web_address.web_address_type_id = EnumKey.find_by_key_and_name(key, "web_address_types").id
      puts "#{web_address.save}"
      puts "later #{web_address.web_address_type_id.to_s}"
    end
    #remove_column :web_addresses, :sort
#    rename_column :web_addresses, :sort, :web_address_type_id
    
  end

  def self.down
    rename_column :web_addresses, :web_address_type_id, :sort
  end
end
