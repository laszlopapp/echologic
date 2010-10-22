class ProposalsController < StatementsController

  #
  # Edit action to incorporate improvement proposals.
  # FIXME: should be handled RESTfully ind the Edit action with an additional
  #        parameter in the URL: .../Pid?approved_node=IPid
  #        Also the edit views should be reused (no edit_draft views)!!!
  #
  def incorporate
    still_approved = true
    has_lock = false
    @approved_node = ImprovementProposal.find params[:approved_ip]
    if @approved_node.approved?
      @approved_document = @approved_node.document_in_preferred_language(@language_preference_list)
    else
      still_approved = false
    end

    @statement_document = @statement_node.document_in_preferred_language(@language_preference_list)
    has_lock = acquire_lock(@statement_document)
    @action ||= StatementAction["incorporated"]
    if still_approved && has_lock
      respond_action 'statements/proposals/edit_draft'
    elsif !still_approved
      respond_to do |format|
        set_info('discuss.statements.not_approved_any_more')
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js do
          render_with_info do |page|
            page << "$('#approved_ip').animate(toggleParams, 500).hide();"
          end
        end
      end
    else
      respond_to do |format|
        set_info('discuss.statements.being_edited')
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js   { render_with_info }
      end
    end
  end

  protected
  # return a possible parent, in this case it's a Question
#  def parent
#    Question.find(params[:question_id])
#  end

  #returns the handled statement type symbol
  def statement_node_symbol
    :proposal
  end

  # returns the statement_node class, corresponding to the controllers name
  def statement_node_class
    Proposal
  end
end
