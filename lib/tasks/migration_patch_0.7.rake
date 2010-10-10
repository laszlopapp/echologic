namespace :db do
  desc "move all Web Address sorts to type_ids"
  task :migration_patch_0_7 => :environment do
    WebAddress.all.each do |web_address|
      if !web_address.sort.nil?
        key = (web_address.sort == 99 ? web_address.sort : web_address.sort + 1)
        web_address.type_id = WebAddressType[key].id
        web_address.save(false)
      end
    end
  end
end