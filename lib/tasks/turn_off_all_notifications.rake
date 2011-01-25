namespace :notifications do
  desc "Turns off all notifications for all users"
  task :turn_off_all => :environment do
    User.all.each do |user|
      user.activity_notification = 0
      user.drafting_notification = 0
      user.newsletter_notification = 0
      user.save(false)
    end
  end

  task :turn_on_for_testers => :environment do
     User.find_all_by_email(['laszlo.papp@echologic.org',
                             'cardoso_tiago@hotmail.com',
                             'jan.linhart@echologic.org']).each do |user|
      user.activity_notification = 1
      user.drafting_notification = 1
      user.newsletter_notification = 1
      user.save(false)
    end
  end

end