class Users::ActivationsController < ApplicationController

  skip_before_filter :require_user
  before_filter :require_no_user

  def new
    later_call(root_path, request.url) do |format|
      format.js {
       @user = User.find_by_perishable_token(params[:activation_code], 1.week)
       if @user.nil?
         set_error "users.activation.messages.no_account"
         render_with_error
       elsif @user.active?
         set_error "users.activation.messages.already_active"
         render_with_error
       else
         render :template => 'users/components/users_form', 
                :locals => {:partial => 'users/activations/new', :css_class => "basic_profile_box"}
       end
       }
    end
  end
 
 

  def create
    @user = User.find_by_perishable_token(params[:activation_code], 1.week)
  
    User.transaction do 
      if @user.nil?
        redirect_or_render_with_error(root_path, "users.activation.messages.no_account")
      elsif @user.active?
        redirect_or_render_with_error(root_path, "users.activation.messages.already_active")
      else
        if @user.email or @user.has_verified_email? params[:user][:email] # given email is a verified email, therefore, no activation is needed
          if @user.activate!(params[:user]) and @user.profile.save # so that the name persists
            UserSession.create(@user, false)
            @user.deliver_activation_confirmation!
            redirect_with_info(root_path, 'users.activation.messages.success')
          else
            set_error 'users.activation.messages.failed'
            redirect_or_render_with_error(url, @user)
          end
        else # given email is not verified, therefore, send activation email
          if !params[:user][:email].blank? and @user.signup!(params[:user]) and @user.profile.save
            @user.deliver_activate! 
            redirect_or_render_with_info(root_path, 'users.users.messages.created') do |page|
              page << "$('#dialogContent').dialog('close');"
            end
          else
            set_error 'users.activation.messages.failed'
            later_call_with_error(request.referer, signup_url, @user)
          end
        end
      end
    end
  end
  
  def activate_email
    @action = PendingAction.find(params[:token])
    
    if @action.nil?
      redirect_or_render_with_error(root_path, "users.activation.messages.no_account")
    elsif @action.status
      redirect_or_render_with_error(root_path, "users.activation.messages.already_active")
    else
      @user = @action.user
      User.transaction do 
        if @user.update_attributes(JSON.parse(@action.action))
          @action.update_attribute(:status, true)
          UserSession.create(@user, false)
          @user.deliver_activation_confirmation!
          redirect_with_info(root_path, 'users.activation.messages.success')
        else
          set_error 'users.activation.messages.failed'
          redirect_or_render_with_error(url, @user)
        end
      end
    end
  end
end
