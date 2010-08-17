class ProposalsController < StatementsController

  def incorporate
    @incorporated_node ||= @statement_node.approved_children.first
    @statement_document ||= @statement_node.document_in_preferred_language(@language_preference_list)
    has_lock = acquire_lock(@statement_document)
    @action ||= StatementHistory.statement_actions("incorporated")
    if has_lock
      respond_to_js :template => 'statements/proposals/edit_draft',
                    :partial_js => 'statements/proposals/edit_draft.rjs'
    else
      respond_to do |format|
        set_info('discuss.statements.being_edited')
        format.html { flash_info and render :template => 'statements/proposals/edit_draft' }
        format.js   { render_with_info }
      end
    end
  end

  protected
  # return a possible parent, in this case it's a Question
  def parent
    Question.find(params[:question_id])
  end

  #returns the handled statement type symbol
  def statement_node_symbol
    :proposal
  end

  # returns the statement_node class, corresponding to the controllers name
  def statement_node_class
    Proposal
  end

  def root_symbol
    nil
  end
end
