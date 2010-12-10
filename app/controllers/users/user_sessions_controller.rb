class Users::UserSessionsController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    @user_session = UserSession.new
    respond_to do |format|
      format.html
    end
  end

  # TODO use redirect back or default! see application controller!
  def create
    redirect_url = params[:user_session].delete(:redirect_url)
    @user_session = UserSession.new(params[:user_session])
    respond_to do |format|
      if @user_session.save
        set_info 'users.user_sessions.messages.login_success'
        format.html { flash_info and redirect_to redirect_url }
      else
        set_error 'users.user_sessions.messages.login_failed'
        format.html { flash_error and redirect_to root_path }
      end
    end
  end

  def destroy
    current_user.update_attributes(:last_login_language => Language[params[:locale]])
    current_user_session.destroy
    reset_session
    set_info 'users.user_sessions.messages.logout_success'
    flash_info and redirect_to root_path
  end
end
