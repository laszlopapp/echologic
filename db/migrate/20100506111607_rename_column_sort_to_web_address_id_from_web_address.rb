class RenameColumnSortToWebAddressIdFromWebAddress < ActiveRecord::Migration
  def self.up
    add_column :web_addresses, :web_address_type_id, :integer
    WebAddress.all.each do |web_address|
      web_address_type = web_address.sort.to_i
      web_address_type += 1 unless web_address_type == 99
      web_address.web_address_type_id = EnumKey.find_by_key_and_name(web_address_type, "web_address_types").id
      web_address.save(false)
    end
    remove_column :web_addresses, :sort
  end

  def self.down
    rename_column :web_addresses, :web_address_type_id, :sort
  end
end
