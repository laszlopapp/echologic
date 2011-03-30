namespace :janrain do
  desc "Turns on newsletter notifications for all users"
  task :delete_all_mappings => :environment do
    mappings = SocialService.instance.all_mappings
    mappings.each do |key, identifiers|
      identifiers.each do |id|
        SocialService.instance.unmap id, key
      end
    end
  end
end