module MyEchoHelper
  
  def social_account_button(provider)
    if current_user.has_provider? provider
      link_to remove_remote_url(provider), :class => 'disconnect' do
        content_tag :span, I18n.t("users.social_accounts.disconnect.title"), :class => "button "
      end
    else
      # first step: create the url to redirect everything in the end
      redirect_url = add_remote_url + '?' + (
        {:authenticity_token => form_authenticity_token}.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
      ).compact.join('&')
      
      # second step: create the url to which we will be redirect at the end of the external login
      token_url = redirect_from_popup_url + '?' + (
      { :redirect_url => redirect_url, :authenticity_token => form_authenticity_token }.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
    ).compact.join('&')
      link_to SocialService.instance.get_provider_signup_url(provider, token_url), :onClick => "return popup(this, true)", :class => 'connect' do
        content_tag :span, I18n.t("users.social_accounts.connect.title"), :class => "button_150"
      end
    end
  end
end