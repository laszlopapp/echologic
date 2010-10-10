module QuestionsHelper
  def add_discussion_link
    link_to(new_question_url,
            :id => "create_question_link") do
      content_tag(:span, '',
                  :class => "new_question create_statement_button_mid create_question_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_question"))

    end
  end

  # Creates a 'Publish' button to release the discussion.
  def publish_button_or_state(statement_node)
    if !statement_node.published?
      link_to(I18n.t("discuss.statements.publish"),
              publish_question_path(statement_node),
              :class => 'ajax_put publish_button ttLink',
              :title => I18n.t('discuss.tooltips.publish'))
    else
      "<span class='publish_button'>#{I18n.t('discuss.statements.states.published')}</span>"
    end
  end
  
  def discussion_title(title,statement_node)
    link_to(h(title),question_url(statement_node), :class => "statement_link ttLink no_border",
            :title => I18n.t("discuss.tooltips.read_#{statement_node.class.name.underscore}")) 
  end
  
  def link_to_question(title, question,long_title)
    link_to question_url(question),
               :title => "#{h(title) if long_title}",
               :class => "avatar_holder#{' ttLink no_border' if long_title }" do 
      image_tag question.image.url(:small)
    end
  end
  
  def questions_count_text(count)
    count_text("discuss", count)
  end
  
  def publish_statement_node_link(statement_node, statement_document)
    if current_user and
       statement_document.author == current_user and !statement_node.published?
      link_to(I18n.t('discuss.statements.publish'),
              { :controller => :questions,
                :action => :publish,
                :in => :summary },
              :class => 'ajax_put header_button text_button publish_text_button ttLink',
              :title => I18n.t('discuss.tooltips.publish'))
    end
  end
end
