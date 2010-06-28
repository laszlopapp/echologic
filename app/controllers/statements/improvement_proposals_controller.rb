class ImprovementProposalsController < StatementsController

  protected
  # return a possible parent, in this case it's a Proposal
  def parent
    Proposal.find(params[:proposal_id])
  end
  
  #returns the handled statement type symbol
  def statement_class_param
    :improvement_proposal
  end
  
  # returns the statement_node class, corresponding to the controllers name
  def statement_node_class
    ImprovementProposal
  end
end
