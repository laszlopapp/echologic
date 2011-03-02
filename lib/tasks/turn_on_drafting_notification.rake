namespace :drafting do
  desc "Turns on drafting notifications for all users"
  task :turn_on_notification => :environment do
    User.active.each do |user|
      user.drafting_notification = 1
      user.save(false)
    end
  end
end