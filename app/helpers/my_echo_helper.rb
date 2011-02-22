module MyEchoHelper
  
  def social_account_button(provider)
    if current_user.has_provider? provider
      link_to '#', :class => 'disconnect' do
        content_tag :span, I18n.t("users.social_accounts.disconnect"), :class => "button "
      end
    else
      link_to '#', :class => 'connect' do
        content_tag :span, I18n.t("users.social_accounts.connect"), :class => "button_150"
      end
    end
  end
end