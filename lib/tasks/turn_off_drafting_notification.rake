namespace :drafting do
  desc "Turns off drafting notifications for all users"
  task :turn_on_notification => :environment do
    User.all.each do |user|
      user.drafting_notification = 0
      user.save(false)
    end
  end
end