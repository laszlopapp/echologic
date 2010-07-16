module QuestionsHelper

  # Returns a comma separated list of all tags to be displayed.
  def tag_list(statement_node)
    statement_node.tags.map{|tag|tag.value}.join(', ')
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

  # Creates a 'New Discussion' button
  def add_discussion_link
    link_to(I18n.t('discuss.statements.create_question_link'),
            new_question_url,
            :id => 'create_question_link',
            :class => 'text_button create_question_button ttLink no_border')
  end

end
