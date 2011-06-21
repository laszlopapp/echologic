module Users::ProfileActionsModule
  
  def details
    @profile = Profile.find(params[:id], :include => [:web_addresses, :memberships, :user])
    respond_to do |format|
      format.js   { render :template => 'connect/profiles/details'}
      format.html { render :partial => 'connect/profiles/details', :layout => 'application' }
    end
  end
  
  def new_mail
    @user = User.find(params[:id]) 
    render_static_new :partial => 'users/profiles/mails/new' do |format| 
      format.js { render :template => 'users/profiles/mails/new' }
    end
  end
  
  def send_mail
    @user = User.find(params[:id])
    MailerService.instance.send_user_mail(current_user, @user, params[:user_mail])

    respond_to do |format|
#      if @report.save
        set_info('users.user_mails.messages.created')
        format.html { flash_info and redirect_to('/connect/search') }
        format.js {render :template => 'users/profiles/mails/create'}
#      else
#        format.html { render :action => "new" }
#        format.js   { set_error @report and render_with_error }
#      end
    end    
  end
    
end