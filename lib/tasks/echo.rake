namespace :echo do
    task :show_all_profiles => :environment do
      User.all.each do |u| u.profile.show_profile = true; u.profile.save! end
    end
end
