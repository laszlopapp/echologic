namespace :rpx do
  desc "Removes all remote mappings in RPX"
  task :delete_all_mappings => :environment do
    puts 'Started... '
    mappings = SocialService.instance.all_mappings
    mappings.each do |user_id, identifiers|
      puts '.'
      SocialService.instance.delete_mappings user_id
      puts 'x'
    end
    SocialIdentifier.destroy_all
  end
end