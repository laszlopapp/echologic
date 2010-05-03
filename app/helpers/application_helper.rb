# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Acl9::Helpers

  # If user is an admin the admin options should be shown.
  access_control :show_admin_options? do
    allow :admin
  end

  # Return a progressbar
  def insert_progressbar(percent)
    tooltip = I18n.t('application.roadmap.progress_tooltip', :progress => percent)
    val =  "<span id='roadmap_progressbar' class='ttLink' title='#{tooltip}'></span>"
    val += "<script type='text/javascript'>$('#roadmap_progressbar').progressbar({value: #{percent != 0 ? percent : 1}});</script>"
    val
  end
  
  def current_language_key
    EnumKey.find_by_name_and_code("languages", I18n.locale.to_s).id
  end
  
  def current_language_keys
    keys = [current_language_key].concat(current_user ? current_user.language_keys : []).uniq
  end
  
end
