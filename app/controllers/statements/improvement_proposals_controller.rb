class ImprovementProposalsController < StatementsController

  protected
  def parent
    Proposal.find(params[:proposal_id])
  end
  
  def statement_class_param
    :improvement_proposal
  end
  
  # returns the statement_node class, corresponding to the controllers name
  def statement_node_class
    ImprovementProposal
  end
end
