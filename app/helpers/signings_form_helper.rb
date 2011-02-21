module SigningsFormHelper
  
  def toggle_form_field(type)
    toggle_type = type.eql?('signin') ? 'signup' : 'signin'
    content = ''
    content << content_tag(:span, "#{I18n.t("users.#{toggle_type}.member_tag")} >>>", :class => 'registry_label')
    content << content_tag(:a, I18n.t("users.#{toggle_type}.label"), :class => 'toggle_button', :href => "##{toggle_type}")
    content
  end
  
  def signing_header(type)
    content = ''
    content << content_tag(:span, content_tag(:h2, I18n.t("users.#{type}.via_echo")), :class => 'box_label')
    content << I18n.t('application.general.or')
    content << content_tag(:span, content_tag(:h2, I18n.t("users.#{type}.via_social")), :class => 'box_label')
    content 
  end
  
  def signin_social_link
    janrain_login_widget signin_remote_url, :language => I18n.locale 
  end
  
  def signup_social_link
    janrain_login_widget signup_remote_url, :language => I18n.locale 
  end
end