module MyEchoHelper
  def social_account_button(provider, token_url)
    if current_user.has_provider? provider
      render :partial => 'users/social_accounts/disconnect', :locals => {:provider => provider}
    else
      render :partial => 'users/social_accounts/connect', :locals => {:provider => provider, :token_url => token_url}
    end
  end
end