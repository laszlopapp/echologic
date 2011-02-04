module TranslationModule
  ################
  # TRANSLATIONS #
  ################

  #
  # Renders the new statement translation form when called
  #
  # Method:   GET
  # Response: JS
  #
  def new_translation
    @statement_document ||= @statement_node.document_in_preferred_language(@language_preference_list)
    if (is_current_document = @statement_document.id == params[:current_document_id].to_i) and
       !(already_translated = @statement_document.language_id == @locale_language_id)
      has_lock = acquire_lock(@statement_document)
      @new_statement_document ||= @statement_node.add_statement_document({:language_id => @locale_language_id})
      @action ||= StatementAction["translated"]
    end
    if !is_current_document
      set_statement_info('discuss.statements.statement_updated')
      render_statement_with_info
    elsif already_translated
      set_statement_info('discuss.statements.already_translated')
      render_statement_with_info
    elsif !has_lock
      set_info('discuss.statements.being_edited')
      render_statement_with_info
    else
      render_template 'statements/new_translation'
    end
  end

  #
  # Creates a translation of a statement according to the fields from a form that was submitted
  #
  # Method:   POST
  # Params:   new_statement_document: hash
  # Response: JS
  #
  def create_translation
    translated = false
    begin
      attrs = params[statement_node_symbol]
      new_doc_attrs = attrs.delete(:new_statement_document).merge({:author_id => current_user.id,
                                                                   :language_id => @locale_language_id,
                                                                   :current => true})
      locked_at = new_doc_attrs.delete(:locked_at)

      # Updating the statement
      holds_lock = true

      StatementNode.transaction do
        old_statement_document = StatementDocument.find(new_doc_attrs[:old_document_id])
        holds_lock = holds_lock?(old_statement_document, locked_at)
        if (holds_lock)
          @new_statement_document = @statement_node.add_statement_document(new_doc_attrs)
          @new_statement_document.save
          @statement_node.save
        end
      end

      # Rendering response
      if !holds_lock
        being_edited
      elsif @new_statement_document.valid?
        translated = true
        @statement_document = @new_statement_document
        set_statement_info(@statement_document)
        show_statement
      else
        @statement_document = StatementDocument.find(new_doc_attrs[:old_document_id])
        set_error(@new_statement_document)
        render_statement_with_error :template => 'statements/new_translation'
      end
    rescue Exception => e
      log_message_error(e, "Error translating statement node '#{@statement_node.id}'.") do
        load_ancestors and flash_error and render :template => 'statements/new_translation'
      end
    else
      log_message_info("Statement node '#{@statement_node.id}' has been translated sucessfully.") if translated
    end
  end
end