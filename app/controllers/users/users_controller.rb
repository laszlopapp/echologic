class Users::UsersController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :update_password, :add_concernments, :delete_concernment]
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
  auto_complete_for :tag, :value, :limit => 5 do |tags|
    content = tags.map{ |tag|
      tag.value.index('*') == 0 ? nil : "#{tag.value}|#{tag.id}"
    }.compact.join("\n")
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

    respond_to do |format|
      format.html { render :template => 'users/users/new', :layout => 'static' } # new.html.erb
      format.js
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # modified users_controller.rb
  def create
    @user = User.new
    @user.create_profile
    respond_to do |format|
      if @user.signup!(params)
        @user.deliver_activation_instructions!
        flash[:notice] = I18n.t('users.users.messages.created')
        format.html { redirect_to root_url }
        format.js do
          render :update do |page|
            page.redirect_to root_url
          end
        end
      else
        format.js   { show_error_messages(@user) }
        format.html { render :template => 'users/users/new', :layout => 'static' }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "User was successfully updated."
        format.html { redirect_to(profile_path) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def update_password
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    respond_to do |format|
      if @user.save and not params[:user][:password].empty?
        format.html { flash[:notice] = I18n.t('users.password_reset.messages.reset_success') and redirect_to my_profile_path }
        format.js   { render_with_info(I18n.t('users.password_reset.messages.reset_success')) }
      else
        format.html { redirect_to my_profile_path }
        format.js   { show_error_messages(@user) }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy
    respond_to do |format|
      flash[:notice] = "User removed, Sir!"
      format.html { redirect_to connect_path }
    end
  end
  
  
  def add_concernments
    previous_completeness = current_user.profile.percent_completed
    concernments = params[:tag][:value]
    new_concernments = concernments.split(',').map!{|t|t.strip} - current_user.send("#{params[:context]}_tags".to_sym)
    all_concernments = current_user.send("#{params[:context]}_tags".to_sym) + new_concernments
    old_concernments_hash = current_user.send("#{params[:context]}_tags_hash".to_sym)
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
          show_error_messages(current_user)
        end
      end
    end
  end
  
  def delete_concernment
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
  end

  private
  
  def fetch_user
    @user = User.find(params[:id]) || current_user
  end

end
