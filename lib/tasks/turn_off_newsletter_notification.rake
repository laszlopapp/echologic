namespace :newsletter do
  desc "Turns off newsletter notifications for all users"
  task :turn_off_notification => :environment do
    User.all.each do |user|
      user.newsletter_notification = 0
      user.save(false)
    end
  end
end