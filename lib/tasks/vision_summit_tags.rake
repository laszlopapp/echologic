namespace :vision_summit do
  desc "Turns on newsletter notifications for all users"
  task :tags => :environment do
    %w(vs11 vision-summit).each do |shortcut|
      ShortcutUrl.discuss_search_shortcut :title => shortcut, :params => {:search_terms => "#vs11 dep"}, :language => "de"
    end
    %w(vf11 vision-fair).each do |shortcut|
      ShortcutUrl.discuss_search_shortcut :title => shortcut, :params => {:search_terms => "vision fair, 2011"}, :language => "de"
    end
  end
end