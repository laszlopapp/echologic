class ImprovementProposalObserver < ActiveRecord::Observer
    def after_update(improvement_proposal)
      most_supported = improvement_proposal.parent.supported_ranking.first
      current_most_supported = improvement_proposal.parent.update_supported_ranking.first
      if most_supported != current_most_supported
        #send email to author
        #set timestamp
      end
    end
end