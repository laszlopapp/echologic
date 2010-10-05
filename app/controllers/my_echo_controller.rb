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

  %w(newsletter activity drafting).each do |notification_type|
    class_eval %(
      def set_#{notification_type}_notification
        @user = User.find(params[:id])
        notify = params.has_key?(:notify)
        @user.#{notification_type}_notification = notify ? 1 : 0
        @user.save
        respond_to do |format|
          format.js do
            set_info("users.notifications.#{notification_type}." + (notify ? 'turned_on' : 'turned_off'))
            render_with_info do
              replace_content('#{notification_type}_notification_element',
                              :partial => 'users/notification/check',
                              :locals => {:notification_type => '#{notification_type}'})
            end
          end
        end
      end
    )
  end
end
