class Users::UsersController < ApplicationController
  helper :signings_form

  before_filter :require_no_user, :only => [:new, :create, :create_social, :setup_basic_profile]
  skip_before_filter :require_user, :only => [:index, :new, :create, :create_social, :setup_basic_profile]
  before_filter :fetch_user, :only => [:show, :setup_basic_profile, :edit, :update, :destroy]
  
  

  access_control do
    allow logged_in, :to => [:show, :index, :update_email, :update_password, :add_concernments, 
                             :delete_concernment, :auto_complete_for_tag_value, :update, :destroy_account, :add_social,
                             :remove_social]
    allow :admin
    allow anonymous, :to => [:new, :create, :create_social, :setup_basic_profile]
  end

  include Users::SocialModule

  # Generate auto completion based on values in the database. Load only 5
  # suggestions a time.
  auto_complete_for :user, :city,    :limit => 5
  auto_complete_for :user, :country, :limit => 5
  auto_complete_for :tag, :value, :limit => 20 do |tags|
    @@tag_filter.call %w(* #), tags
  end


  # GET /users
  # GET /users.xml
  def index
    @users = User.all
    respond_to do |format|
      format.html
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  
  # GET /users/new
  # GET /users/new.xml
  def new
    session[:redirect_url] = request.referer
    @user ||= User.new
    @user_session ||= UserSession.new
    @to_show = "signup"
    render_static_new :template => 'users/users/new' do |format|
      format.js {render :template => 'users/components/users_form', 
                        :locals => {:partial => 'users/users/new'}}
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # modified users_controller.rb
  def create
    redirect_url = session[:redirect_url] || root_path
    @user = User.new
    @user.create_profile
    begin
      respond_to do |format|
        if @user.signup!(params[:user])
          @user.deliver_activation_instructions!
          set_info 'users.users.messages.created'
          format.html { flash_info and redirect_to redirect_url }
          format.js {
            render_with_info do |page|
              page << "$('#dialogContent').dialog('close');"
            end
          }
        else
          set_error @user
          set_later_call signup_url
          format.html { flash_error and flash_later_call and redirect_to redirect_url }
          format.js{render_with_error}
        end
      end
    rescue Exception => e
      log_message_error(e, "Error creating user")
    else
      log_message_info("User '#{@user.id}' has been created sucessfully.")
    end
  end

  

  # PUT /users/1
  # PUT /users/1.xml
  def update
    begin
      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:notice] = "User was successfully updated."
          format.html { redirect_to(profile_path) }
        else
          format.html { render :action => "edit" }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error updating user #{@user.id}")
    else
      log_message_info("User '#{@user.id}' has been updated sucessfully.")
    end
  end
  
  def update_email
    respond_to do |format|
      if current_user.update_attributes(params[:user])
        set_info "users.echo_account.change_email.success"
        format.html {flash_info and redirect_to settings_path}
        format.js {
          render_with_info
        }
      else
        set_error current_user
        format.html { flash_error and redirect_to settings_path }
        format.js{ render_with_error }
      end
    end
  end

  def update_password
    old_password = params[:old_password]
    begin
      respond_to do |format|
        if current_user.has_password? old_password
          if current_user.update_attributes(params[:user])
            set_info 'users.echo_account.change_password.success'
            format.html { flash_info and redirect_to settings_path }
            format.js   { render_with_info }
          else
            set_error current_user
            format.html { flash_error and redirect_to settings_path }
            format.js   { render_with_error }
          end
        else
          set_error "users.echo_account.change_password.wrong_password"
          format.html { flash_error and redirect_to settings_path }
          format.js   { render_with_error }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error updating user #{current_user.id} password")
    else
      log_message_info("User '#{current_user.id}' password has been updated sucessfully.")
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    begin
      @user.delete_account
      respond_to do |format|
        flash[:notice] = "User account has been removed."
        format.html { redirect_to connect_path }
      end
    rescue Exception => e
      log_message_error(e, "Error deleting account from user '#{@user.id}'.")
    else
      log_message_info("User '#{@user.id}' account has been sucessfully deleted.")
    end
  end

  def destroy_account
    begin
      current_user_session.destroy
      reset_session
      current_user.delete_account
      respond_to do |format|
        set_info "users.echo_account.delete_account.success"
        format.html { flash_info and redirect_to root_path }
      end
    rescue Exception => e
      log_message_error(e, "Error deleting account from user '#{current_user.id}'.")
    else
      log_message_info("User '#{current_user.id}' account has been sucessfully deleted.")
    end
  end

  def add_concernments
    concernments = params[:tag][:value]
    new_concernments = concernments.split(',').map!{|t|t.strip} - current_user.send("#{params[:context]}_tags".to_sym)
    all_concernments = current_user.send("#{params[:context]}_tags".to_sym) + new_concernments
    old_concernments_hash = current_user.send("#{params[:context]}_tags_hash".to_sym)
    begin
      previous_completeness = current_user.profile.percent_completed
      current_user.send("#{params[:context]}_tags=".to_sym, all_concernments)
      respond_to do |format|
        format.js do
          if current_user.save and current_user.profile.save
            current_completeness = current_user.profile.percent_completed
            if previous_completeness != current_completeness
              set_info("discuss.messages.new_percentage", :percentage => current_completeness)
            end
            new_concernments_hash = current_user.send("#{params[:context]}_tags_hash").to_a - old_concernments_hash.to_a
            render_with_info do |p|
              p.insert_html :bottom, "concernments_#{params[:context]}",
                            :partial => "users/concernments/concernment",
                            :collection => new_concernments_hash,
                            :locals => {:context => params[:context]}
              p << "$('#new_concernment_#{params[:context]}').reset();"
              p << "$('#concernment_#{params[:context]}_id').focus();"
            end
          else
            set_error current_user and render_with_error
          end
        end
      end
    rescue Exception => e
      log_message_error(e, "Error adding concernments '#{new_concernments}'.")
    else
      log_message_info("Concernments '#{new_concernments}' have been added sucessfully.")
    end
  end

  def delete_concernment
    begin
      previous_completeness = current_user.percent_completed
      current_user.send("#{params[:context]}_tags=", current_user.send("#{params[:context]}_tags") - [params[:tag]])
      current_user.save
      current_user.profile.save
      current_completeness = current_user.percent_completed
      if previous_completeness != current_completeness
        set_info("discuss.messages.new_percentage", :percentage => current_completeness)
      end

      respond_to do |format|
        format.js do
          render_with_info do |p|
            p.remove "#{params[:context]}_#{params[:id]}"
          end
        end
      end
    rescue Exception => e
      log_message_error(e, "Error deleting concernment '#{params[:tag]}'.")
    else
      log_message_info("Concernment '#{params[:tag]}' has been deleted sucessfully.")
    end
  end

  private

  def fetch_user
    @user = User.find(params[:id]) || current_user
  end

  def user_not_active?
    !@user.active
  end

end
