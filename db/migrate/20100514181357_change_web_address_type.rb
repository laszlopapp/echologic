class ChangeWebAddressType < ActiveRecord::Migration
  def self.up
    WebAddress.all.each do |web_address|
      key = (web_address.sort == 99 ? web_address.sort : web_address.sort + 1)
      web_address.web_address_type = EnumKey.find_by_key_and_enum_name(key, "web_address_types")
      web_address.save(false)
    end
    
  end

  def self.down
    
  end
end
