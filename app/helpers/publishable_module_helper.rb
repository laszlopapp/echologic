module PublishableModuleHelper
  #
  # get the text that shows up on the top left corner of discuss search results
  #
  def discussions_count_text(count, value = nil)
    text = count_text("discuss", count)
    text << " #{I18n.t('discuss.for', :value => value)}" if value
    text
  end


  #
  # create discussion button above the discuss search results and on the left corner of my discussions
  #
  def create_discussion_link_for(path, value=nil)
    link_to(send("new_discussion_with_path#{value ? '_and_value' : ''}_url", :path => path, :value => value),
            :id => 'create_discussion_link') do
      content_tag(:span, '',
                  :class => "new_discussion create_statement_button_mid create_discussion_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_discussion"))
    end
  end
  
  
  #
  # discussion link for the discuss search results
  #
  def link_to_discussion(title, discussion,long_title,value=nil)
    link_to send("statement_node_with_path#{value ? '_and_value' : ''}_url", 
                 discussion, :path => :discuss_search, :value => value),
               :title => "#{h(title) if long_title}",
               :class => "avatar_holder#{' ttLink no_border' if long_title }" do 
      image_tag discussion.image.url(:small)
    end
  end
  

  #
  # Creates a link to create a new discussion
  # Appears in add discussion teaser
  #
  def create_new_discussion_link(path=nil, value=nil)
    value = (value =~ /#/) ? value : nil
    link_to(I18n.t("discuss.statements.create_discussion_link"),
            send("new_discussion#{path ? '_with_path' : '' }#{value ? '_and_value' : ''}_url", 
            :path => path, :value => value),
            :id => "create_discussion_link",
            :class => "ajax add_new_button text_button create_discussion_button ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_discussion"))
  end

  #
  # Creates a button link to create a new discussion (SIDEBAR).
  #
  def create_new_discussion_button(path = nil, value = nil)
    value = (value =~ /#/) ? value : nil
    link_to(send("new_discussion#{path ? '_with_path' :''}#{value ? '_and_value' : '' }_url", 
                  :path => path, :value => value),
                  :id => "create_discussion_link", :class => "ajax") do
      content_tag(:span, '',
                  :class => "create_statement_button_mid create_discussion_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_discussion"))

    end
  end



  #
  # publish button that appears on the right top corner of the statement 
  #
  def publish_statement_node_link(statement_node, statement_document)
    if current_user and
       statement_document.author == current_user and !statement_node.published?
      link_to(I18n.t('discuss.statements.publish'),
              { :controller => :statements,
                :action => :publish,
                :in => :summary },
              :id => 'publish_button', 
              :class => 'ajax_put header_button text_button publish_text_button ttLink',
              :title => I18n.t('discuss.tooltips.publish'))
    else
      ''
    end
  end
  
  #
  # linked title of discussion on my discussion area 
  #
  def my_discussion_title(title,discussion)
    link_to(h(title),statement_node_with_path_url(discussion, :path => :my_discussions), :class => "statement_link ttLink no_border",
            :title => I18n.t("discuss.tooltips.read_#{discussion.class.name.underscore}")) 
  end
  
  #
  # linked image of discussion on my discussion area 
  #
  def my_discussion_image(discussion)
    link_to statement_node_with_path_url(discussion, :path => :my_discussions), :class => "avatar_holder" do
      image_tag discussion.image.url(:small)
    end 
  end

  # Creates a 'Publish' button to release the discussion on my discussions area.
  def publish_button_or_state(statement_node)
    if !statement_node.published?
      link_to(I18n.t("discuss.statements.publish"),
              publish_statement_node_path(statement_node),
              :class => 'ajax_put publish_button ttLink',
              :title => I18n.t('discuss.tooltips.publish'))
    else
      "<span class='publish_button'>#{I18n.t('discuss.statements.states.published')}</span>"
    end
  end
  
  # returns a collection from possible statement states to be used on radios and select boxes
  def statement_states_collection
    StatementState.all.map{|s|[I18n.t("discuss.statements.states.initial_state.#{s.code}"),s.id]}
  end
end