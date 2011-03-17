# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Acl9::Helpers

  # If user is an admin the admin options should be shown.
  access_control :show_admin_options? do
    allow :admin
  end

  # Creates a 'Save or Cancel' block at the bottom of forms.
  def save_or_cancel(cancel_action)
    val = submit_tag I18n.t('application.general.save'),
                     :class => 'text_button save_text_button'
    val << content_tag(:span, I18n.t('application.general.or'), :class => 'or_button')
    val << link_to(I18n.t('application.general.cancel'),
                   cancel_action,
                  :class => 'ajax text_button cancel_text_button')
    val
  end

  def load_submenu(key)
    content_for :submenu, tabnav(key)
    if block_given?
      yield
    else
      content_for :section, key
    end
  end
  

  # Return a progressbar
  def insert_progressbar(percent)
    tooltip = I18n.t('application.roadmap.progress_tooltip', :progress => percent)
    val =  content_tag :span, :id => 'roadmap_progressbar',  :class => 'ttLink', :title => tooltip
    val += javascript_tag "$('#roadmap_progressbar').progressbar({value: #{percent != 0 ? percent : 1}});"
    val
  end

  def insert_separator_line
    content_tag :span, '', :class => 'shadow_line_separator'
  end

  def count_text(key, count)
    I18n.t("#{key}.results_count.#{count == 1 ? 'one' : 'more'}", :count => count)
  end


  # Inserts text area with the given text and two butt
  # Click-functions are added via jQuery, take a look at application.js
  def insert_toggle_more(text)
    concat("<span class='hideButton' style='display:none;'>#{I18n.t('application.general.hide')}</span>")
    concat("<span class='moreButton'>#{I18n.t('application.general.more')}</span>")
    concat("<div class='toggled_content' style='display: none;'>")
      concat("#{text}")
    concat("</div>")
  end

  # Container is only visible in echologic
  def display_echologic_container
    request[:controller].eql?('static/echologic') ? '' : "style='display:none'"
  end

  # tabContainer is not visible in echologic
  def display_tab_container
    request[:controller].eql?('static/echologic') ? "style='display:none'" : ''
  end

  # Inserts the breadcrumb for the given main and sub menu point
  def insert_breadcrumb(main_link, sub_link, sub_menu_title='.title',sub_menu_subtitle='.subtitle', show_illustration=true)
    controller = request[:controller].split('/')[1]
    action = request[:action]
    title_translation = I18n.t("static.#{controller}.title")
    if main_link != sub_link
      show_illustration(show_illustration,controller,action)
      subtitle_translation = I18n.t("static.#{controller}.#{action}" + sub_menu_title)
    else
      subtitle_translation = I18n.t("static.#{controller}#{sub_menu_subtitle}")
    end

    main_menu = "<h1 class='link'>#{title_translation}</h1>"
    concat link_to(main_menu, url_for(:controller => controller, :action => 'show'))
    concat "<h2>#{subtitle_translation}</h2>"
  end

  # gets the latest twittered content of the specified user account
  # via json.
  # RESCUES: SocketError, Exception
  def get_twitter_content
    begin
      require 'open-uri'
      require 'json'
      buffer = open("http://twitter.com/users/show/echologic.json").read
      result = JSON.parse(buffer)
      html = content_tag(:span,
                         l(result['status']['created_at'].to_date, :format => :long),
                         :id => 'twitter_date')
      html += content_tag(:span, auto_link(result['status']['text'],
                                           :html => {:target => "_blank"}),
                          :id => 'twitter_text')
    rescue Exception => e
      logger.error "#{Time.now.utc.strftime("%m/%d/%Y %H:%M")} - Failed to display Twitter message"
      logger.error e.backtrace
      content_tag :span, "Tweet! Tweet! :-)", :id => 'twitter_text'
    end
  end

  def build_static_menu_button(item)
    val =  "<span class='img #{item}_image'>&nbsp;</span>"
    %w(title subtitle).each do |type|
      val += "<span class='#{type}'>" + I18n.t("static.#{item}.#{type}")    + "</span><br/>"
    end
    val
  end
  
  ########################
  # POP-UP LOGIN HELPERS #
  ########################
  
  def redirect_token_url(opts= {})
    # first step: create the url to redirect everything in the end
    redirect_url = add_remote_url + '?' + (
      opts.merge({:authenticity_token => form_authenticity_token}).collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
    ).compact.join('&')
    
    # second step: create the url to which we will be redirect at the end of the external login
    token_url = redirect_from_popup_url + '?' + (
    { :redirect_url => redirect_url, 
      :authenticity_token => form_authenticity_token }.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
    ).compact.join('&')
    token_url
  end
  
  
  def janrain_login_widget(token_url, options={})
    url = token_url + '?' + (
      { :authenticity_token => form_authenticity_token }.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
    ).compact.join('&')
    <<-EOF
    <iframe src='http://#{ENV['ECHO_RPX_APP_NAME']}/openid/embed?#{embed_params(url)}' scrolling='no' frameBorder='no'  
    allowtransparency='true' style='width:400px;height:240px'></iframe>
    EOF
  end
  
  def embed_params(url, options={})
    {
      :token_url => CGI::escape( url ),
      :language_preference => options[:language],
      :flags => options[:flags],
      :default_provider => options[:default_provider]
    }.map{|k,v| "#{k}=#{v}" if v}.compact.join('&amp;')
  end
end
