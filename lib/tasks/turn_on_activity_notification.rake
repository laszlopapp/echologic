namespace :activity_tracking do
  desc "Turns on activity notifications for all users"
  task :turn_on_notification => :environment do
    User.all.each do |user|
      user.activity_notification = 1
      user.save
    end
  end
end