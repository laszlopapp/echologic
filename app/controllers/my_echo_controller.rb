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
  
  
  %w(email drafting).each do |attr|
    class_eval %(
      def set_#{attr}_notification
        @user = User.find(params[:id])
        notify = params.has_key?(:notify)
        @user.#{attr}_notification = notify ? 1 : 0
        @user.save
        respond_to do |format|
          format.js do
            set_info("users.#{attr}_notifications."+(notify ? '#{attr}_on' : '#{attr}_off'))
            render_with_info do
              replace_content('#{attr}_notification_element',:partial => 'users/notification/check', :locals => {:attr => '#{attr}'})
            end
          end
        end
      end
    )
  end
end
