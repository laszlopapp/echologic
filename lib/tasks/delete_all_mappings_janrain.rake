namespace :janrain do
  desc "Turns on newsletter notifications for all users"
  task :delete_all_mappings => :environment do
    mappings = SocialService.instance.delete_mappings
  end
end