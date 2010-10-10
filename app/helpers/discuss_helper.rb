module DiscussHelper
  
  def search_category(category)
    content_tag :span, 
                I18n.t('discuss.search.in', :category => I18n.t("discuss.topics.#{category}.short_name")), 
                :class => "search_category" if category
  end
  
  
end
