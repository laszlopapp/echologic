module ConnectHelper

  def open_profile_details(profile)
    link_to url_for(:controller => 'users/profile',
                    :action => 'details',
                    :id => profile),
            :class => 'ajax show_link avatar_holder' do
      image_tag profile.avatar.url(:small), :alt => ''
    end
  end

  def close_profile_details
    link_to I18n.t('application.general.close'), connect_search_path,
        :id => 'close_details_container',
        :class => 'close_link',
        :onclick => "$('.profile').removeClass('active');
                     $.scrollTo('top', 400, function(){
                       $('#profile_details_container').animate(toggleParams, 500);
                     });
                     return false;"
  end

  def profiles_count_text(count, search_terms, sort_id)
    key = "connect.results_count"
    sort = sort_id.blank? ? nil : TagContext[sort_id.to_i] 
    num = count == 1 ? 'one' : 'more'
    cond = search_terms.blank? ? '' : '.with_terms'
    count_text = count.to_s
    count_text << if sort.nil? 
                    I18n.t("#{key}.member.#{num}")
                  else
                    I18n.t("#{key}.sorted_member#{cond}.#{num}", :sort => I18n.t("#{key}.sort.#{num}.#{sort.code}"))
                end
    count_text << (search_terms.blank? ? '' : I18n.t("#{key}.terms.#{sort.nil? ? 'no_sort' : sort.code}", :terms => search_terms))
    count_text
  end
end
