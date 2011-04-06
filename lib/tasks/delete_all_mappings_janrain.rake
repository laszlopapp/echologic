namespace :janrain do
  desc "Removes all remote mappings in RPX"
  task :delete_all_mappings => :environment do
    mappings = SocialService.instance.all_mappings
    mappings.each do |user_id, identifiers|
      SocialService.instance.delete_mappings user_id
    end
  end
end