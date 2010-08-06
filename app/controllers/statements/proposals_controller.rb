class ProposalsController < StatementsController
  
  def incorporate
    @incorporated_node ||= @statement_node.approved_children.first
    @statement_document ||= @statement_node.translated_document(@language_preference_list)
    @action ||= StatementHistory.statement_actions("incorporate")
    respond_to_js :template => 'statements/proposals/edit_draft', 
                  :partial_js => 'statements/proposals/edit_draft.rjs'
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
