class Users::ActivationsController < ApplicationController

  skip_before_filter :require_user
  before_filter :require_no_user

 def new
    respond_to do |format|
      format.html {
        set_later_call request.url
        flash_later_call and redirect_to root_path
      }
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

    respond_to do |format|
      User.transaction do 
        if @user.nil?
          set_error "users.activation.messages.no_account"
          format.html { flash_error and redirect_to root_url }
          format.js{ render_with_error }
        elsif @user.active?
          set_error "users.activation.messages.already_active"
          format.html { flash_error and redirect_to root_url }
          format.js{ render_with_error }
        else
          if @user.email or @user.has_verified_email? params[:user][:email] # given email is a verified email, therefore, no activation is needed
            if @user.activate!(params[:user]) and @user.profile.save # so that the name persists
              UserSession.create(@user, false)
              @user.deliver_activation_confirmation!
              set_info 'users.activation.messages.success'
              flash_info
              format.html { redirect_to_home }
              format.js{
                render :update do |page|
                  page.redirect_to root_path
                end
              }
            else
              set_error 'users.activation.messages.failed'
              set_error @user
              format.html { flash_error and redirect_to root_url }
              format.js{ render_with_error }
            end
          else # given email is not verified, therefore, send activation email
            if !params[:user][:email].blank? and @user.signup!(params[:user]) and @user.profile.save
              @user.deliver_activation_request! 
              set_info 'users.users.messages.created'
              format.html { flash_info and redirect_to root_path }
              format.js {
                render_with_info do |page|
                  page << "$('#dialogContent').dialog('close');"
                end
              }
            else
              set_error 'users.activation.messages.failed'
              set_error @user
              set_later_call signup_url
              format.html { flash_error and flash_later_call and request.referer }
              format.js{ render_with_error }
            end
          end
        end
      end
    end
  end




end
