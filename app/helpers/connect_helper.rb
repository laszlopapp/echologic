module ConnectHelper
  
  def open_profile_details(profile)
    link_to url_for(:controller => 'users/profile',:action => 'details',:id => profile),:class => 'ajax show_link avatar_holder' do 
      image_tag profile.avatar.url(:small)
    end 
  end
  
  def close_profile_details
    link_to I18n.t('application.general.close'), connect_path,
        :id => 'close_details_container',
        :class => 'close_link',
        :onclick => "$j('.profile').removeClass('active');
                     $j.scrollTo('top', 400, function(){
                       $j('#profile_details_container').animate(toggleParams, 500);
                     });
                     return false;"
  end
  
  def profiles_count_text(count)
    count_text("connect", count)
  end
end
