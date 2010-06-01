module DiscussHelper
  def add_discussion_link
    link_to(I18n.t("discuss.statements.create_question_link"),new_question_url,
            :id => "create_question_link",
            :class => "text_button ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_question"))
  end
  
  def tag_list(statement)
    statement.tags.map{|tag|tag.value}.join(',')
  end
  
  def publish_button(statement)
    link_to('', publish_question_path(statement), :class => 'ajax_put publish_button', :value => I18n.t("discuss.statements.publish"))
  end
end
