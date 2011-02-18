class Users::ActivationsController < ApplicationController

  skip_before_filter :require_user
  before_filter :require_no_user, :only => [:new, :create]

  def new
    respond_to do |format|
      format.html {
        set_later_call request.url
        flash_later_call and redirect_to root_url
      }
      format.js {
        @user = User.find_by_perishable_token(params[:activation_code], 1.week) || (raise Exception)
        raise Exception if @user.active?
        render :template => 'users/activations/new'
      }
    end
  end

  def create
    @user = User.find(params[:id])

    raise Exception if @user.active?
    respond_to do |format|
      User.transaction do 
        if @user.activate!(params[:user]) and @user.profile.save # so that the first and last name persist
          @user.deliver_activation_confirmation!
          set_info 'users.activation.messages.success'
          flash_info
          format.html { redirect_to_home }
          format.js{
            render :update do |page|
              page.redirect_to root_url
            end
          }
        else
          set_error 'users.activation.messages.failed'
          format.html { flash_error and redirect_to root_url }
          format.js{ render_with_error }
        end
      end
    end
  end




end
