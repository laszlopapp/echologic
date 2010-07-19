module QuestionsHelper
  def add_discussion_link
    link_to(image_tag("page/discuss/add_question_big.png",
                        :class => 'right_block_illustration'),
            new_question_url,
            :id => "create_question_link",
            :class => "ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_question"))
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
end
