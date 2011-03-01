namespace :newsletter do
  desc "Turns on newsletter notifications for all users"
  task :turn_on_notification => :environment do
    User.active.each do |user|
      user.newsletter_notification = 1
      user.save(false)
    end
  end
end