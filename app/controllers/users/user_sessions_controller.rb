class Users::UserSessionsController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create, :create_social]
  skip_before_filter :require_user, :only => [:new, :create, :create_social]

  def new
    session[:redirect_url] = request.referer
    render_signinup :signin
  end

  # TODO use redirect back or default! see application controller!
  def create
    redirect_url = session[:redirect_url] || root_path
    begin
      User.transaction do 
        @user_session = UserSession.new(params[:user_session])
        if @user_session.save
          # if the user failed to log in with a social account just previously,
        # this will be added as the user logs in with its' echo account
          add_social_to_user(User.find_by_email(params[:user_session][:email])) if session[:identifier]
  
          redirect_with_info(redirect_url, 'users.signin.messages.success')
        else
          later_call_with_error(redirect_url, signin_path, 'users.signin.messages.failed')
        end
      end
    rescue RpxService::RpxServerException
      redirect_or_render_with_error(redirect_url, "application.remote_error")
    rescue Exception => e
      log_message_error(e, "Error logging in with echo account")
    end
  end

  def create_social
    redirect_url = session[:redirect_url] || root_path
    begin
      profile_info = SocialService.instance.get_profile_info(params[:token])
      user = nil
      User.transaction do
        if profile_info['primaryKey'].nil? or (user = User.find(profile_info['primaryKey'])).nil?
          session[:identifier] = profile_info.to_json
          invalid_social = SocialIdentifier.find_by_identifier(profile_info['identifier'])
          invalid_social.destroy if invalid_social
          later_call_with_error(redirect_url, signin_path, 'users.signin.messages.failed_social')
        else
          if social = user.identified_by?(profile_info['identifier'])
            social.update_attribute(:profile_info, profile_info.to_json)
          else
            user.add_social_identifier( profile_info['identifier'], profile_info['providerName'], profile_info.to_json )
          end
          if user.active? # user was already actived, i.e. he has an email account defined
            @user_session = UserSession.new(user)
            if @user_session.save
              redirect_or_render_with_info(redirect_url, 'users.signin.messages.success')
            else
              redirect_or_render_with_error(redirect_url, 'users.signin.messages.failed')
            end
          else # user doesn't have an email account, so he should go get it
            later_call_with_info(redirect_url, setup_basic_profile_url(user.perishable_token))
          end
        end
      end
    rescue RpxService::RpxServerException
      redirect_or_render_with_error(redirect_url, "application.remote_error")
    rescue Exception => e
      log_message_error(e, "Error logging in with social account")
    end
  end

  def destroy
    current_user.update_attributes(:last_login_language => Language[params[:locale]])
    current_user_session.destroy
    reset_session
    set_info 'users.signout.messages.success'
    flash_info and redirect_to root_path
  end

  protected
  def add_social_to_user(user)
    profile_info = JSON.parse(session[:identifier])
    social_identifier =  SocialIdentifier.create(:identifier => profile_info['identifier'],
                                                 :provider_name => profile_info['providerName'],
                                                 :profile_info => session[:identifier],
                                                 :user => user)
    session.delete(:identifier)
    SocialService.instance.map(social_identifier.identifier, user.id)
  end
end
