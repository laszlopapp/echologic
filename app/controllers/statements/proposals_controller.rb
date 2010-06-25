class ProposalsController < StatementsController

  protected
  def parent
    Question.find(params[:question_id])
  end
  
  def statement_class_param
    :proposal
  end
  
  # returns the statement_node class, corresponding to the controllers name
  def statement_node_class
    Proposal
  end
end
