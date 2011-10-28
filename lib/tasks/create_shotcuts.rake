namespace :create_shortcuts do
  desc "Turns on newsletter notifications for all users"
  task :vision_summit_2011 => :environment do
    %w(vs11 vision-summit visionsummit).each do |shortcut|
      ShortcutUrl.discuss_search_shortcut :title => shortcut,
                                          :params => {:search_terms => "vision-summit-2011"},
                                          :language => "de"
    end
    %w(vf11 vision-fair visionfair).each do |shortcut|
      ShortcutUrl.discuss_search_shortcut :title => shortcut,
                                          :params => {:search_terms => "vision-fair-2011"},
                                          :language => "de"
    end
  end

  task :apold => :environment do
    %w(allam-polgari-dialogus apold).each do |shortcut|
      ShortcutUrl.discuss_search_shortcut :title => shortcut,
                                          :params => {:search_terms => "Állam-POLgári-Dialógus, ÁPOLD-Kezdőlap"},
                                          :language => "hu"
    end
  end

  task :szocikon => :environment do
    %w(szocialis-konzultacio szocikon).each do |shortcut|
      ShortcutUrl.statement_shortcut :title => shortcut,
                                     :params => { :id => 1555 },
                                     :language => "hu"
    end
    %w(vonalkod kakaostej).each do |shortcut|
      ShortcutUrl.discuss_search_shortcut :title => shortcut,
                                          :params => {:search_terms => "vonalkód, kakaóstej"},
                                          :language => "hu"
    end
  end

  task :embed_echo_discussion => :environment do
    %w(embed-echo-discussion).each do |shortcut|
      ShortcutUrl.statement_shortcut :title => shortcut,
                                     :params => { :id => 1901 },
                                     :language => "en"
    end
  end

end