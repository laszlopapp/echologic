# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Acl9::Helpers

  # If user is an admin the admin options should be shown.
  access_control :show_admin_options? do
    allow :admin
  end

  def save_or_cancel(cancel_action)
    val = submit_tag I18n.t('application.general.save'),
                     :class => 'text_button save_button'
    val << "<span class='or_button'>"
    val << I18n.t('application.general.or')
    val << "</span>"
    val << link_to(I18n.t('application.general.cancel'),
                   cancel_action,
                  :class => 'ajax text_button cancel_text_button')
    val
  end

  # Return a progressbar
  def insert_progressbar(percent)
    tooltip = I18n.t('application.roadmap.progress_tooltip', :progress => percent)
    val =  "<span id='roadmap_progressbar' class='ttLink' title='#{tooltip}'></span>"
    val += "<script type='text/javascript'>$('#roadmap_progressbar').progressbar({value: #{percent != 0 ? percent : 1}});</script>"
    val
  end

  def insert_separator_line
    "<span class='shadow_line_separator'></span>"
  end

end
