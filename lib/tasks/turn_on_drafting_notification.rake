namespace :drafting do
  desc "Initializes the drafting state machine for all Improvement Proposals"
  task :turn_on_notification => :environment do
    User.all.each do |user|
      user.drafting_notification = 1
      user.save
    end
  end
end