module Users::SocialModule
  
  def create_social
    redirect_url = session[:redirect_url] || root_path
    token = params[:token]
    profile_info = SocialService.instance.get_profile_info(token)
    
    @user = User.new
    @user.create_profile
    
    opts = SocialService.instance.load_basic_profile_options(profile_info) || {}
    opts[:social_identifiers] = [SocialIdentifier.new(:identifier => profile_info['identifier'], 
                                                        :provider_name => profile_info['providerName'],
                                                        :profile_info => profile_info.to_json )]
    
    begin
      User.transaction do
        respond_to do |format|
          if @user.signup!(opts)
            set_later_call setup_basic_profile_url(@user.perishable_token)
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
  
  def add_social
    token = params[:token]
    begin
      profile_info = SocialService.instance.get_profile_info(token)
      social_id = current_user.add_social_identifier( profile_info['identifier'], profile_info['providerName'], profile_info.to_json )
      respond_to do |format|
        if social_id.save
          set_info "users.social_accounts.connect.success", :account => I18n.t("users.social_accounts.providers.#{profile_info['providerName'].underscore}")
          format.html { flash_info and redirect_to settings_path }
        else
          set_error set_info "users.social_accounts.connect.failed", :account => I18n.t("users.social_accounts.providers.#{profile_info['providerName'].underscore}")
          format.html { flash_error and redirect_to redirect_url }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error adding social account to user")
    else
      log_message_info("User '#{current_user.id}' added a new social account successfully.")
    end
  end
  
  def remove_social
    provider = params[:provider]
    begin
      respond_to do |format|
        if social_id = current_user.has_provider?(provider)
           social_id.destroy
           set_info "users.social_accounts.disconnect.success", 
                    :account => I18n.t("users.social_accounts.providers.#{profile_info['providerName'].underscore}")
           format.html { flash_info and redirect_to settings_path }
           format.js { 
            render_with_info do |page|
             
            end
           }
        else
          set_error set_info "users.social_accounts.disconnect.failed", 
          :account => I18n.t("users.social_accounts.providers.#{profile_info['providerName'].underscore}")
          format.html { flash_error and redirect_to redirect_url }
          format.js { render_with_error }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error removing social account to user")
    else
      log_message_info("User '#{current_user.id}' removed a social account successfully.")
    end
  end
  
  def setup_basic_profile
    session[:redirect_url] = request.referer
    @user = User.find_by_perishable_token(params[:activation_code], 1.week)
    @profile_info = JSON.parse(@user.social_identifiers.first.profile_info)
    if @user.nil?
      set_error "users.activation.messages.no_account"
      format.html { flash_error and redirect_to root_url }
      format.js{ render_with_error }
    elsif @user.active?
      set_error "users.activation.messages.already_active"
      format.html { flash_error and redirect_to root_url }
      format.js{ render_with_error }
    else
      render_static_new :template => 'users/users/setup_basic_profile' do |format|
        format.js {render :template => 'users/components/users_form', 
                          :locals => {:partial => 'users/users/setup_basic_profile', :css_class => "basic_profile_box"}}
      end
    end
  end

end