class Users::UsersController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create, :create_rpx]
  skip_before_filter :require_user, :only => [:index, :new, :create, :create_rpx]
  before_filter :fetch_user, :only => [:show, :setup_basic_profile, :edit, :update, :update_password, :destroy]
  

  access_control do
    allow logged_in, :to => [:show, :index, :setup_basic_profile, :update_password, :add_concernments, :delete_concernment, :auto_complete_for_tag_value, :update]
    allow :admin
    allow anonymous, :to => [:new, :create, :create_rpx]
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

  def setup_basic_profile
    session[:redirect_url] = request.referer
    @profile_info = JSON.parse(@user.social_identifiers.first.profile_info)
    render_static_new :template => 'users/users/setup_basic_profile'
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    session[:redirect_url] = request.referer
    @user ||= User.new
    @user_session ||= UserSession.new
    @to_show = "signup"
    render_static_new :template => 'users/users/new'
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

  def create_rpx
    redirect_url = session[:redirect_url] || root_path
    token = params[:token]
    profile_info = SocialService.get_profile_info(token)
    
    @user = User.new
    @user.create_profile
    
    opts={}
    opts[:email] = profile_info['email']
    opts[:first_name] = profile_info['name']['givenName']
    opts[:last_name] = profile_info['name']['familyName']
    opts[:social_identifiers] = []
    opts[:social_identifiers] << SocialIdentifier.new(:identifier => profile_info['identifier'], 
                                                      :provider_name => profile_info['providerName'],
                                                      :profile_info => profile_info.to_json )
    
    begin
      User.transaction do
        respond_to do |format|
          if @user.activate!(opts)
            set_later_call setup_basic_profile_user_url(@user)
            format.html { flash_later_call and redirect_to redirect_url }
          else
            set_error @user
            @user.social_identifiers.each {|id| set_error(id)} if !@user.social_identifiers.blank?
            set_later_call signup_url
            format.html { flash_later_call and flash_error and redirect_to redirect_url }
          end
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
    redirect_url = session[:redirect_url] || my_profile_path
    begin
      User.transaction do 
        respond_to do |format|
          if @user.update_attributes(params[:user]) and @user.profile.save
            set_info "users.activation.messages.success"
            format.html { flash_info and redirect_to redirect_url}
          else
            set_error @user
            format.html { flash_error and redirect_to request.referer }
          end
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

  private

  def fetch_user
    @user = User.find(params[:id]) || current_user
  end

  def user_not_active?
    !@user.active
  end

end
