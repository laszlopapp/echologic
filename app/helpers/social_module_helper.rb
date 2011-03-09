module SocialModuleHelper
  def social_account_button(provider)
    if current_user.has_provider? provider
      render :partial => 'users/social_accounts/disconnect', :locals => {:provider => provider}
    else
      render :partial => 'users/social_accounts/connect', :locals => {:provider => provider}
    end
  end
  
  def create_token_url(provider)
    # first step: create the url to redirect everything in the end
    redirect_url = add_remote_url + '?' + (
      {:authenticity_token => form_authenticity_token}.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
    ).compact.join('&')
    
    # second step: create the url to which we will be redirect at the end of the external login
    token_url = redirect_from_popup_url + '?' + (
    { :redirect_url => redirect_url, :authenticity_token => form_authenticity_token }.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
    ).compact.join('&')
    token_url
  end
end