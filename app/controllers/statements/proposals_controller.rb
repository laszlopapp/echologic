class ProposalsController < StatementsController

  def incorporate
    still_approved = true
    has_lock = false
    @approved_node = ImprovementProposal.find params[:approved_ip]
    if @approved_node.approved?
      @approved_document = @approved_node.document_in_original_language
    else
      still_approved = false
    end

    @statement_document = @statement_node.document_in_preferred_language(@language_preference_list)
    has_lock = acquire_lock(@statement_document)
    @action ||= StatementHistory.statement_actions("incorporated")
    if still_approved && has_lock
      respond_to_js :template => 'statements/proposals/edit_draft',
                    :partial_js => 'statements/proposals/edit_draft.rjs'
    elsif !still_approved
      respond_to do |format|
        set_info('discuss.statements.not_approved_any_more')
        format.html { flash_info and render :template => 'statements/show' }
        format.js do
          render_with_info do |page|
            page << "$('#approved_ip').animate(toggleParams, 500).hide();"
            #page.remove 'approved_ip'
          end
        end
      end
    else
      respond_to do |format|
        set_info('discuss.statements.being_edited')
        format.html { flash_info and render :template => 'statements/show' }
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
