namespace :janrain do
  desc "Turns on newsletter notifications for all users"
  task :delete_all_mappings => :environment do
    mappings = SocialService.instance.all_mappings
    mappings.each do |user_id, identifiers|
      SocialService.instance.delete_mappings user_id
    end
  end
end