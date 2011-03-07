module EchoableModule
  ###################
  # ECHO STATEMENTS #
  ###################

  #
  # Called if user supports this statement_node. Updates the support field in the corresponding
  # echo object.
  #
  # Method:   POST
  # Response: JS
  #
  def echo
    begin
      return if !@statement_node.echoable?
      if !@statement_node.incorporable? or @statement_node.parent.supported?(current_user)
        @statement_node.supported!(current_user)
        set_statement_info('discuss.statements.statement_supported')
        respond_to_js :redirect_to => statement_node_url(@statement_node), :template_js => 'statements/echo'
      else
        set_info('discuss.statements.unsupported_parent')
        render_statement_with_info
      end
    rescue Exception => e
      log_error_statement(e, "Error echoing statement node '#{@statement_node.id}'.")
    else
      log_message_info("Statement node '#{@statement_node.id}' has been echoed sucessfully.")
    end
  end

  #
  # Called if user doesn't support this statement_node any longer. Sets the supported field
  # of the corresponding echo object to false.
  #
  # Method:   POST
  # Response: HTTP or JS
  #
  def unecho
    begin
      return if !@statement_node.echoable?

      @statement_node.unsupported!(current_user)
      
      
      if @statement_node.draftable?
        @statement_node.children.each{|c|c.unsupported!(current_user) if c.incorporable? and c.supported?(current_user)}
      end
      
      # Logic to update the children caused by cascading unsupport
      @page = params[:page] || 1
      set_statement_info('discuss.statements.statement_unsupported')
      respond_to_js :redirect_to => statement_node_url(@statement_node),
                    :template_js => 'statements/unecho'
    rescue Exception => e
      log_error_statement(e, "Error unechoing statement node '#{@statement_node.id}'.")
    else
      log_message_info("Statement node '#{@statement_node.id}' has been unechoed sucessfully.")
    end
  end
  
  #
  # Called if user wants to share his echo in his social networks. Creates a shortcut url for this.
  #
  # Method:   GET
  # Response: HTTP or JS
  #
  def social_widget
    if @statement_node.supported?(current_user)
#      current_user.update_social_accounts
      @statement_document ||= @statement_node.document_in_preferred_language(@language_preference_list)
      command = {:operation => "statement_node", :params => {:id => @statement_node.id}, :language => @statement_document.language.code}.to_json
      @shortcut_url = ShortcutUrl.find_or_create(:shortcut => @statement_document.title, 
                                                 :human_readable => true, :shortcut_command => {:command => command})
      respond_to do |format|
        format.js { render :template => "statements/social_widget" }
      end
    else
      set_error "discuss.statements.supporter_to_share"
      render_statement_with_error
    end
  end

  protected
  #
  # Loads the echo/unecho messages as JSON data to handled on the client
  #
  def load_echo_info_messages
    @messages = {:supported => set_statement_info('discuss.statements.statement_supported'),
                 :not_supported => set_statement_info('discuss.statements.statement_unsupported')}.to_json
  end
  

  def is_echoable?
    @statement_node.echoable?
  end
end