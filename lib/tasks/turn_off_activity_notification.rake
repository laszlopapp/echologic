namespace :activity_tracking do
  desc "Turns off activity notifications for all users"
  task :turn_on_notification => :environment do
    User.all.each do |user|
      user.activity_notification = 0
      user.save(false)
    end
  end
end