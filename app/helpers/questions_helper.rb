module QuestionsHelper
  def add_discussion_link
    link_to(I18n.t("discuss.statements.create_question_link"),new_question_url,
            :id => "create_question_link",
            :class => "text_button create_question_button ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_question"))
  end
  
  def publish_button(statement_node)
    link_to(I18n.t("discuss.statements.publish"),
            publish_question_path(statement_node),
            :class => 'ajax_put publish_button ttLink',
            :title => I18n.t('discuss.tooltips.publish'))
  end
end
