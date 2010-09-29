# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Acl9::Helpers

  # If user is an admin the admin options should be shown.
  access_control :show_admin_options? do
    allow :admin
  end

  # Creates a 'Save or Cancel' block at the bottom of forms.
  def save_or_cancel(cancel_action)
    val = submit_tag I18n.t('application.general.save'),
                     :class => 'text_button save_button'
    val << content_tag(:span, I18n.t('application.general.or'), :class => 'or_button')
    val << link_to(I18n.t('application.general.cancel'),
                   cancel_action,
                  :class => 'ajax text_button cancel_text_button')
    val
  end

  # Return a progressbar
  def insert_progressbar(percent)
    tooltip = I18n.t('application.roadmap.progress_tooltip', :progress => percent)
    val =  content_tag :span, :id => 'roadmap_progressbar',  :class => 'ttLink', :title => tooltip
    val += javascript_tag "$('#roadmap_progressbar').progressbar({value: #{percent != 0 ? percent : 1}});"
    val
  end

  def insert_separator_line
    content_tag :span, :class => 'shadow_line_separator'
  end

  def count_text(key,count)
    I18n.t("#{key}.results_count.#{count < 2 ? 'one' : 'more'}", :count => count)
  end
  
end
