namespace :db do
  desc "move all Web Address sorts to type_ids"
  task :migration_patch_7 => :environment do 
    WebAddress.all.each do |web_address|
      if !web_address.sort.nil?
        key = (web_address.sort == 99 ? web_address.sort : web_address.sort + 1)
        web_address.type_id = EnumKey.find_by_key_and_enum_name(key, "web_address_types").id
        web_address.save(false)
      end
    end
  end
end