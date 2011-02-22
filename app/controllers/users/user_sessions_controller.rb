class Users::UserSessionsController < ApplicationController
  helper :signings_form

  before_filter :require_no_user, :only => [:new, :create, :create_social]
  skip_before_filter :require_user, :only => [:new, :create, :create_social]

  def new
    session[:redirect_url] = request.referer
    @user_session = UserSession.new
    @user ||= User.new
    @to_show = "signin"
    render_static_new :template => 'users/user_sessions/new' do |format|
      format.js {render :template => 'users/components/users_form', 
                        :locals => {:partial => 'users/user_sessions/new'}}
    end
    
  end

  # TODO use redirect back or default! see application controller!
  def create
    redirect_url = session[:redirect_url] || root_path
    
    # if the user failed to log in with a social account just previously, 
    # this will be added as the user logs in with its' echo account
    if session[:identifier]
      profile_info = JSON.parse(session[:identifier])
      s_id = SocialIdentifier.new(:identifier => profile_info['identifier'], :provider_name => profile_info['providerName'],
                                  :profile_info => session[:identifier], :user => User.find_by_email(params[:user_session][:email]))
      session[:identifier] = nil
    end
    
    @user_session = UserSession.new(params[:user_session])
    respond_to do |format|
      if @user_session.save
        s_id.save if s_id
        set_info 'users.signin.messages.success'
        flash_info
        format.html { redirect_to redirect_url }
        format.js{
          render :update do |page|
            page.redirect_to redirect_url
          end
        }
      else
        set_error 'users.signin.messages.failed'
        set_later_call signin_path
        format.html { flash_error and flash_later_call and redirect_to redirect_url }
        format.js{ render_with_error }
      end
    end
  end

  def create_social
    redirect_url = session[:redirect_url] || root_path
    token = params[:token]
    profile_info = SocialService.instance.get_profile_info(token)
    identifier = profile_info['identifier']
    user = User.find_by_social_identifier(identifier)
    
    if user.nil?
      respond_to do |format|
        set_error 'users.signin.messages.failed_social'
        set_later_call signin_path
        session[:identifier] = profile_info.to_json
        format.html { flash_error and flash_later_call and redirect_to redirect_url }
      end
    else
      @user_session = UserSession.new(user)
      respond_to do |format|
        if @user_session.save
          set_info 'users.signin.messages.success'
          format.html { flash_info and redirect_to redirect_url }
        else
          set_error 'users.signin.messages.failed'
          format.html { flash_error and redirect_to redirect_url }
        end
      end
    end
  end

  def destroy
    current_user.update_attributes(:last_login_language => Language[params[:locale]])
    current_user_session.destroy
    reset_session
    set_info 'users.signout.messages.success'
    flash_info and redirect_to root_path
  end
end
