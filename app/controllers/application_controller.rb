# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  ###########
  # ROUTING #
  ###########

  #
  # Initialize the locale of the application
  #
  before_filter :set_locale

  private
  # Takes the locale from the URL or return the most matching one for the IP.
  def set_locale
    available = %w{en de es pt fr}
    I18n.locale = params[:locale] ? params[:locale].to_sym : request.compatible_language_from(available)
  end

  #
  # Redirect all old (echologic.org) deep links to the current host (echo.to)
  #
  before_filter :redirect_to_new_host

  private
  def redirect_to_new_host
    if defined?(OLD_ECHO_HOST) && request.host.include?(OLD_ECHO_HOST)
      new_url = request.protocol + ECHO_HOST + request.request_uri
      redirect_to new_url, :status => :moved_permanently
    end
  end

  #
  # False URLs are redirected to home
  #
  rescue_from 'ActionController::RoutingError', :with => :rescure_routing_error
  rescue_from 'ActionController::UnknownAction', :with => :rescure_routing_error
  rescue_from 'ActiveRecord::RecordNotFound', :with => :rescure_routing_error

  private
  def rescure_routing_error
    redirect_to_url last_url, 'application.routing_error'
  end

  private
  # Called when when a routing error occurs.
  def redirect_to_home
    redirect_to discuss_search_url
  end

  private
  def last_url
    request.referer || root_url
  end

  protected
  def redirect_to_url(url, message)
    respond_to do |format|
      set_info message
      format.html do
        flash_info and redirect_to url
      end
      format.js do
        render_with_info do |page|
          page << "redirectToUrl('#{params[:controller]}', '#{url}');"
        end
      end
    end
  end


  ############################
  # ACCESS RIGHTS MANAGEMENT #
  ############################

  # Authlogic authentication filters
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user

  # Catch access denied exception in the whole application and handle it
  rescue_from 'Acl9::AccessDenied', :with => :access_denied

  private
  #
  # If access is denied display warning and redirect to users_path
  #
  def access_denied
    flash[:error] = I18n.t('activerecord.errors.messages.access_denied')
    redirect_to_home
  end

  before_filter :require_user, :except => [:shortcut]

  private
  # Before filter used to define which controller actions require an active and valid user session.
  def require_user
    @user_required = true
    unless current_user
      set_info('authlogic.error_messages.must_be_logged_in')
      respond_to do |format|
        format.html {
          flash_info
          redirect_to request.url == last_url ? root_url : last_url
        }
        format.js {
          render_with_info do |page|
            page << "$('#user_session_email').focus();"
          end
        }
      end
      return false
    end
  end

    # Checks that the user is NOT logged in.
  def require_no_user
    if current_user
      redirect_to_url root_url, 'authlogic.error_messages.must_be_logged_out'
    end
    return false
  end


  ####################
  # SESSION HANDLING #
  ####################

  # Session timeout
  before_filter :check_session_lifetime

  private
  # Makes the session expire if it is too old
  def check_session_lifetime
    if current_user_session and session[:expiry_time] and session[:expiry_time] < Time.now
      expire_session!
    end
    session[:expiry_time] = MAX_SESSION_PERIOD.seconds.from_now
    return true
  end

  # Expires and cleans up the user session.
  def expire_session!
    current_user.update_attributes(:last_login_language => Language[I18n.locale])
    current_user_session.try(:destroy)
    reset_session
    if params[:controller] == 'users/user_sessions' && params[:action] == 'destroy'
      # If the user wants to log out, we go to the root page and display the logout message.
      redirect_to_url root_url, 'users.user_sessions.messages.logout_success'
    else
      # Not logout
      @user_required ||= false
      if @user_required
        # Login is required but the session is killed
        redirect_to_url last_url, 'users.user_sessions.messages.session_timeout'
      else
        # Login free area
        redirect_to_url request.url, 'users.user_sessions.messages.session_timeout'
      end
    end
  end

  # Return current session if one exists
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  # Returns the currently logged in user
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end


  ############
  # SECURITY #
  ############

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery

  rescue_from 'ActionController::InvalidAuthenticityToken', :with => :invalid_auth_token

  private
  #
  # Called when the authentication token is invalid. It might happen if the user is inactive for a too long time
  # or in case of a CSRF attack.
  #
  def invalid_auth_token
    expire_session!
  end

  # Filters out tags that should not be displayed. It's a lambda in order to be callable from closures.
  @@tag_filter = lambda do |prefixes, tags, max_length|
    tags.map {|tag|
      !prefixes.select{|p| tag.value.index(p) == 0}.empty? ? nil : "#{tag.value}"
    }.compact[0..(max_length-1)].join("\n")
  end


  #############
  # LANGUAGES #
  #############

  protected
  def locale_language_id
    Language[I18n.locale].id
  end

  def language_preference_list
    priority_languages = (@statement_node.nil? ? [locale_language_id] : [locale_language_id,
                                                                        @statement_node.original_language.id])
    priority_languages.concat(current_user ? current_user.sorted_spoken_languages : []).uniq
  end


  #########################
  # Info & error messages #
  #########################

  protected
  # Sets the @info variable to the localisation given through the string
  def set_info(string, options = {})
    @info ||= ""
    @info << "<br/>" if !@info.blank?
    @info << I18n.t(string, options)
  end

  # Sets the @info variable for the flash object (used for HTTP requests)
  def flash_info(message=@info)
    flash[:notice] = message
  end

  # Renders :updates a page with an a info message set by set_info.
  def render_with_info(message=@info)
    render :update do |page|
      page << "info('#{escape_javascript(message)}');" if message
      yield page if block_given?
    end
  end

  # Sets error to the given objects error message.
  # If it's a string then use it as localisation key, else
  # check if it's ActiveRecord object and use the error
  # method on it.
  def set_error(object, options = {})
    if object.kind_of?(String)
      @error = I18n.t(object, options)
    elsif object.class.kind_of?(ActiveRecord::Base.class) && object.errors.count > 0
      value = I18n.t('activerecord.errors.template.body')
      value += "<ul>"
      object.errors.each do |attr_name, message|
        value += "<li>#{message}</li>"
      end
      value += "</ul>"
      if @error.nil?
        @error = value
      else
        @error << value
      end
    end
  end

  #
  # sets an url which will be called assynchronously as the page loads on the user's side
  #
  def set_later_call(url)
    @later_call = url
  end

  # Sets the @error variable for the flash object (used for HTTP requests).
  def flash_error
    flash[:error] = @error
  end

  # Sets the @later_call variable for the flash object (used for HTTP requests).
  def flash_later_call
    flash[:later_call] = @later_call
  end

  # Get formatted error string from error partial for a given object, then show
  # it on the page object as an error message.
  def render_with_error(message=@error)
    render :update do |page|
      page << "error('#{escape_javascript(message)}');"
      yield page if block_given?
    end
  end


  ############################
  # DOM manipulation methods #
  ############################

  protected
  # Helper method to do simple ajax replacements without writing a new template.
  # This small methods takes much complexness from the controllers.
  def replace_container(name, content)
    render :update do |page|
      page << "$('##{name}').replaceWith('#{escape_javascript(render(content))}');"
      yield page if block_given?
    end
  end

  # Helper method to do simple ajax replacements without writing a new template.
  # This small methods takes much complexness from the controllers.
  def replace_content(name, content)
    render :update do |page|
      page.replace_html name, content
    end
  end

  # Helper method to remove some identifier from the page.
  def remove_container(name)
    render :update do |page|
      page.remove name
    end
  end

  def requires_login
    render :update do |page|
    end
  end


  #############
  # RENDERING #
  #############

  protected
  def respond_to_js(opts={})
    respond_to do |format|
      format.html { redirect_to opts[:redirect_to] } if opts[:redirect_to]
      [:template,:partial].each{|t| format.html { render t => opts[t] } if opts[t]}
      [:template,:partial].each{|t| format.js { render t => opts["#{t.id2name}_js".to_sym] } if opts["#{t.id2name}_js".to_sym]}
      yield format if block_given?
    end
  end

  def render_static_show(opts={})
    opts[:partial] ||= 'show'
    opts[:layout] ||= 'static'
    opts[:locals] ||= {}
    respond_to do |format|
      format.html { render :partial => opts[:partial], :layout => opts[:layout]}
      format.js   { render :template => 'layouts/tabContainer', :locals => opts[:locals]}
    end
  end

  def render_static_new(opts={})
    opts[:layout] ||= 'static'
    respond_to do |format|
      [:template,:partial].each{|t|format.html { render t => opts[t], :layout => opts[:layout] } if opts[t]}
      format.js if !block_given?
      yield format if block_given?
    end
  end

  def render_static_outer_menu(opts={})
    opts[:layout] ||= 'static'
    respond_to do |format|
      format.html { render :partial => opts[:partial], :layout => opts[:layout], :locals => opts[:locals]}
      format.js   { render :template => 'layouts/outerMenuDialog' , :locals => opts[:locals]}
    end
  end

  def render_signings(type)
    render_static_new :template => "users/#{type}/new" do |format|
      format.js {render :template => 'users/components/users_form',
                        :locals => {:partial => "users/#{type}/new"}}
    end
  end

  def redirect_or_render_with_info(url, message_or_object, opts={})
    respond_to do |format|
      set_info message_or_object, opts
      format.html { flash_info and redirect_to url }
      format.js   {
        render_with_info do |page|
          yield page if block_given?
        end
      }
    end
  end

  def redirect_or_render_with_error(url, message_or_object, opts={})
    respond_to do |format|
      set_error message_or_object, opts
      format.html { flash_error and redirect_to url }
      format.js   {
        render_with_error do |page|
          yield page if block_given?
        end
      }
    end
  end

  def redirect_with_info(url, message_or_object, opts={})
    set_info message_or_object, opts
    flash_info
    respond_to do |format|
      format.html { redirect_to url }
      format.js{
        render :update do |page|
          page.redirect_to url
        end
      }
    end
  end

  def later_call_with_info(url, later_url, message_or_object=nil, opts={})
    respond_to do |format|
      set_info(message_or_object, opts) if message_or_object
      set_later_call later_url
      format.html {
        flash_info if message_or_object
        flash_later_call
        redirect_to url
      }
      yield format if block_given?
    end
  end

  def later_call_with_error(url, later_url, message_or_object, opts={})
    respond_to do |format|
      set_error(message_or_object, opts)
      set_later_call later_url
      format.html { flash_error and flash_later_call and redirect_to url }
      format.js{ render_with_error }
    end
  end


  #############
  #  LOGGING  #
  #############

  protected
  def log_message_info(message)
    timestamp = Time.now.utc.strftime("%m/%d/%Y %H:%M")
    user = current_user.nil? ? 'not logged in' : current_user.id
    request_url = request.url
    info_message = "Time:'#{timestamp}', User:#{user}, URL:#{request_url} : #{message}"
    logger.info(info_message)
  end

  def log_message_error(e, message)
    timestamp = Time.now.utc.strftime("%m/%d/%Y %H:%M")
    user = current_user.nil? ? 'not logged in' : current_user.id
    request_url = request.url
    error_message = "Time:'#{timestamp}', User:#{user}, URL:#{request_url} : #{message}"
    logger.error(error_message)
    log_error e
    respond_to do |format|
      set_error('application.unexpected_error')
      format.html {yield if block_given?}
      format.js   { render_with_error }
    end
  end

  public
  def shortcut
    respond_to do |format|
      if shortcut = ShortcutUrl.find(params[:shortcut])
         command = JSON.parse(shortcut.command)
         url = send("#{command['operation']}_path", command['params'].merge({:locale => command['language']}))
         format.html {redirect_to url}
      else
        format.html do
          redirect_to discuss_search_url(:search_terms => params[:shortcut])
        end
      end
    end
  end

  def redirect_from_popup
    @redirect_url = params[:redirect_url].split('&').concat(["token=#{params[:token]}"]).join('&')
    respond_to do |format|
      format.html{ render :template => "redirect_from_popup"}
    end
  end
end
