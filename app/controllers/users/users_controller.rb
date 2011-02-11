class Users::UsersController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:index, :new, :create]
  before_filter :fetch_user, :only => [:show, :edit, :update, :update_password, :destroy]


  access_control do
    allow logged_in, :to => [:show, :index, :update_password, :add_concernments, :delete_concernment, :auto_complete_for_tag_value]
    allow :admin
    allow anonymous, :to => [:new, :create]
  end

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
    @user = User.new
    @to_show = params[:id]
    render_static_new :template => 'users/users/new', :layout => 'lightbox'
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # modified users_controller.rb
  def create

    @user = User.new
    @user.create_profile
    begin
      respond_to do |format|
        if @user.signup!(params)
          @user.deliver_activation_instructions!
          set_info 'users.users.messages.created'
          format.html {
            flash_info and redirect_to root_url
          }
          format.js do
            render_with_info do |page|
              page.redirect_to root_url
            end
          end
        else
          set_error @user
          format.html { flash_error and render :template => 'users/users/new', :layout => 'static' }
          format.js   { render_with_error }
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

  def update_password
    begin
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      respond_to do |format|
        if @user.save and not params[:user][:password].empty?
          set_info 'users.password_reset.messages.reset_success'
          format.html {
            flash_info and redirect_to my_profile_path
          }
          format.js   { render_with_info }
        else
          set_error @user
          format.html { flash_error and redirect_to my_profile_path }
          format.js   { render_with_error }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error updating user #{@user.id} password")
    else
      log_message_info("User '#{@user.id}' password has been updated sucessfully.")
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.delete_account
    respond_to do |format|
      flash[:notice] = "User account has been removed."
      format.html { redirect_to connect_path }
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

  # This action has the special purpose of receiving an update of the RPX identity information
  # for current user - to add RPX authentication to an existing non-RPX account.
  # RPX only supports :post, so this cannot simply go to update method (:put)
  def addrpxauth
    @user = current_user
    if @user.save
      @user.deliver_activation_instructions!
      set_info  = "Successfully added RPX authentication for this account."
      format.html {
        flash_info and redirect_to root_url
      }
      format.js do
        render_with_info do |page|
          page.redirect_to root_url
        end
      end
    else
      set_error @user
      format.html { flash_error and render :template => 'users/users/new', :layout => 'static' }
      format.js   { render_with_error }
    end
  end

  private

  def fetch_user
    @user = User.find(params[:id]) || current_user
  end

end
