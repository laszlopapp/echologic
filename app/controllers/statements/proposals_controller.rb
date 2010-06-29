class ProposalsController < StatementsController

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
end
