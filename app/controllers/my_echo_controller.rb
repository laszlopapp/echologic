class MyEchoController < ApplicationController

  before_filter :require_user

  helper :profile

  access_control do
    allow logged_in
  end

  def roadmap
    respond_to do |format|
      format.html
    end
  end

  def profile
    @profile = @current_user.profile
    @user    = @current_user
    @locale_language_id = locale_language_id
    render
  end

  def welcome
    render
  end
   
  def settings
    @profile = @current_user.profile
    @user    = @current_user
    render
  end
  
  def set_email_notification
    @user = User.find(params[:id])
    @user.email_notification = params.has_key?(:notify) ? 1 : 0 
    @user.save
    respond_to do |format|
      format.js do 
        replace_content('email_notification_element', :partial => 'users/email_notification/check')
      end
    end
  end
end
