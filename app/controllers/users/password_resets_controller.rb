# A password reset will be used to give Users the possibility to update
# their password. Authentification based on authlogic's perishable_token.
#
class Users::PasswordResetsController < ApplicationController

  skip_before_filter :require_user
  # Use perishable_token on edit or update methods
  before_filter :load_user_using_perishable_token, :only => [:update]

  # Render password reset creation partial
  def new
    render_static_new :template => 'users/password_resets/new' do |format|
      format.js { render :template => 'users/password_resets/new' }
    end
  end

  # Creates a new password reset process and sends an email to the user.
  def create
    @user = User.find_by_email(params[:email])
    begin
      respond_to do |format|
        if @user
          @user.deliver_password_reset_instructions!
          set_info 'users.password_reset.messages.success'
          flash_info
          format.html { redirect_to root_url }
          format.js   { 
            render :update do |page|
              page.redirect_to root_url
            end
          }
        else
          set_error 'users.password_reset.messages.not_found'
          set_later_call new_password_reset_path
          format.html { flash_error and flash_later_call and redirect_to root_url }
          format.js   { render_with_error }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error creating user '#{@user.nil? ? params[:email] : @user.id}' password.")
    else
      log_message_info("User '#{@user.nil? ? params[:email] : @user.id}' password has been created sucessfully.")
    end
  end

  # Render the edit partial
  def edit
    respond_to do |format|
      format.html { 
        set_later_call request.url
        flash_later_call and redirect_to root_url 
      }
      format.js {
        load_user_using_perishable_token(true)
        render :template => 'users/password_resets/edit'
      }
    end
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.active = true
    begin
      respond_to do |format|
        if @user.save
          set_info 'users.password_reset.messages.reset_success'
          flash_info
          format.html { redirect_to root_url }
          format.js   { 
            render :update do |page|
              page.redirect_to root_url
            end
          }
        else
          set_error 'users.password_reset.messages.reset_failed'
          set_error @user
          set_later_call request.referer
          format.html { flash_error and flash_later_call and redirect_to root_url }
          format.js   { render_with_error }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error updating user '#{@user.id}' password.")
    else
      log_message_info("User '#{@user.nil? ? params[:email] : @user.id}' password has been updated sucessfully.")
    end
  end

  # ------------------------------------------------------------------
  # PRIVATE
  #
  private

  def load_user_using_perishable_token(js=false)
    @user = User.find_by_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account. " +
        "If you are having issues try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
        if js
          render :update do |page|
            page.redirect_to root_url
          end
        else
          redirect_to root_url
        end
    end
  end

end
