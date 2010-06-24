class ImprovementProposalsController < StatementsController

  def parent
    Proposal.find(params[:proposal_id])
  end

end
