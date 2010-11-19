module DiscussionsHelper
  
  
  #
  # Creates a link to create a new discussion
  # Appears in add discussion teaser
  #
  def create_new_discussion_link(value=nil)
    category = value =~ /#/ ? value : nil
    link_to(I18n.t("discuss.statements.create_discussion_link"),
            new_discussion_url(:category => category),
            :id => "create_discussion_link",
            :class => "ajax add_new_button text_button create_discussion_button ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_discussion"))
  end
  
  
  
  
  def link_to_discussion(title, discussion,long_title,value=nil)
    link_to statement_node_url(discussion, :path => :discuss_search, :value => value),
               :title => "#{h(title) if long_title}",
               :class => "avatar_holder#{' ttLink no_border' if long_title }" do 
      image_tag discussion.image.url(:small)
    end
  end
  
  def discussions_count_text(count, value = nil)
    text = count_text("discuss", count)
    text << " #{I18n.t('discuss.for', :value => value)}" if value
    text
  end
  
  
  
  def create_discussion_link_for(category=nil)
    link_to(new_discussion_path(:category => category),
            :id => 'create_discussion_link') do
      content_tag(:span, '',
                  :class => "new_discussion create_statement_button_mid create_discussion_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_discussion"))
    end
  end
end
