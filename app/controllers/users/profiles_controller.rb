class Users::ProfilesController < ApplicationController
  helper :connect

  skip_before_filter :require_user, :only => [:details]

  access_control do
    allow logged_in # Logged in persons are allowed to modify their profile
  end

  def details
    @profile = Profile.find(params[:id], :include => [:web_addresses, :memberships, :user])
    respond_to do |format|
      format.js   { render :template => 'connect/profiles/details'}
      format.html { render :partial => 'connect/profiles/details', :layout => 'application' }
    end
  end

  # Shows details for the current user, this action is formaly known as
  # profile! ;)
  def show
    @profile = Profile.find(params[:id])
    respond_to_js :partial => 'users/profile/profile_own' do |format|
      format.js {replace_container('personal_container', :partial => 'users/profile/profile_own')}
    end
  end

  # Edit the profile details through rendering the edit partial to the
  # corresponding part of the profiles page.
  def edit
    @profile = @current_user.profile
    @profile = Profile.find(params[:id]) if current_user.has_role?(:admin)
    respond_to do |format|
      format.html do
        render :partial => "edit", :layout => "application"
      end
      format.js do
        replace_container('personal_container', :partial => 'edit')
      end
    end
  end

  # Set the values from the edit form to the users attributes.
  def update
    @profile = @current_user.profile
    begin
      respond_to do |format|
        previous_completeness = @profile.percent_completed
        if @profile.update_attributes(params[:profile])
          current_completeness = @profile.percent_completed
          set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness

          format.html { flash_info and redirect_to my_profile_path }
          format.js   {
            render_with_info do |p|
              p.replace('personal_container', :partial => 'users/profile/profile_own')
            end
          }
        else
          format.js { set_error @profile and render_with_error }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error updating profile '#{@profile.id}'.")
    else
      log_message_info("Profile '#{@profile.id}' has been updated sucessfully.")
    end
  end

  # Calls a js template which opens the upload picture dialog.
  def upload_picture
    @user = current_user
    @profile = current_user.profile
    respond_to do |format|
      format.js do
        render :template => 'users/avatar/upload_picture'
      end
    end
  end

  # After uploading the profile picture has to be reloaded.
  # Reloading:
  #  1. login_container with users picture as profile link
  #  2. picture container of the profile
  def reload_pictures
    @user = current_user
    @profile = current_user.profile
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace 'login_container', :partial => 'users/user_sessions/login'
          page.replace 'profile_avatar_container', :partial => 'users/avatar/picture'
        end
      end
    end
  end

end
