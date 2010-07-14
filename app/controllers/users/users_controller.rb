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
  

#  # Direct definition of the tag value autocomplete, as we need more than the default function can give us
#  def auto_complete_for_tag_value
#    find_options = { 
#      :conditions => [ "LOWER(value) LIKE ? and not (position('*' in value) = 0 )", '%' + params[:q].downcase + '%' ], 
#      :order => "value ASC",
#      :limit => 5 }
#    
#    @items = Tag.find(:all, find_options)
#
#    render :inline => "<%= auto_complete_result @items, 'value' %>"
#  end

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
    concernments = params[:tag][:value].split(',').map!{|t|t.strip}
    context = EnumKey.find(params[:context_id])
    new_concernments = concernments - current_user.concernments.in_context(context).map{|concernment|concernment.tag.value}
    current_user.add_tags(new_concernments, {:language_id => locale_language_id, :context_id => params[:context_id]})
   current_user.profile.calculate_completeness

    respond_to do |format|
      format.js do
        if current_user.profile.save
          current_completeness = current_user.profile.percent_completed
          if previous_completeness != current_completeness
            set_info("discuss.messages.new_percentage", :percentage => current_completeness)
          end
          concernments_to_show = current_user.concernments.in_context(context).select do |concernment|
            new_concernments.include? concernment.tag.value
          end
          render_with_info do |p|
            p.insert_html :bottom, "concernments_#{context.code}",
                          :partial => "users/concernments/concernment",
                          :collection => concernments_to_show
            p.visual_effect :appear, dom_id(concernments_to_show.last) unless concernments_to_show.empty?
            p << "$('#new_concernment_#{context.code}').reset();"
            p << "$('#concernment_#{context.code}_id').focus();"
          end
        else
          show_error_messages(current_user)
        end
      end
    end
  end
  
  def delete_concernment
    @concernment = TaoTag.find(params[:id])
    previous_completeness = current_user.percent_completed
    @concernment.destroy
    current_user.profile.calculate_completeness
    current_user.save
    current_completeness = current_user.percent_completed
    if previous_completeness != current_completeness
      set_info("discuss.messages.new_percentage", :percentage => current_completeness)
    end

    respond_to do |format|
      format.js do
        render_with_info do |p|
          p.remove dom_id(@concernment)
        end
      end
    end
  end

  private
  
  def fetch_user
    @user = User.find(params[:id]) || current_user
  end

end
