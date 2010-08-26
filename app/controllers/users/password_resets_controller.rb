# A password reset will be used to give Users the possibility to update
# their password. Authentification based on authlogic's perishable_token.
#
class Users::PasswordResetsController < ApplicationController

  # Use perishable_token on edit or update methods
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  # Render password reset creation partial
  def new
    render_new :template => 'users/password_resets/new' do |format|
      format.js { render :template => 'users/users/new' }
    end
  end

  # Creates a new password reset process and sends an email to the user.
  def create
    @user = User.find_by_email(params[:email])

    respond_to do |format|
      if @user
        @user.deliver_password_reset_instructions!
        set_info('users.password_reset.messages.success')
        format.html { flash_info and redirect_to root_url }
        format.js   { render_with_info(message) }
      else
        set_error('users.password_reset.messages.not_found')
        format.html { flash_error and render :action => :new, :layout => 'static' }
        format.js   { show_error_message(message) }
      end
    end
  end

  # Render the edit partial
  def edit
    respond_to do |format|
      format.html { render :template => 'users/password_resets/edit', :layout => 'static' }
    end
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.active = true
    if @user.save
      flash[:notice] = I18n.t('users.password_reset.messages.reset_success')
      redirect_to welcome_path
    else
      flash[:error] = I18n.t('users.password_reset.messages.reset_failed')
      render :action => :edit, :layout => 'static'
    end
  end

  # ------------------------------------------------------------------
  # PRIVATE
  #
  private

  def load_user_using_perishable_token
    @user = User.find_by_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account. " +
        "If you are having issues try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
      redirect_to root_url
    end
  end

end
