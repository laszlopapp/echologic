class ImprovementProposalObserver < ActiveRecord::Observer
    def after_save(improvement_proposal)
      raise "Improvement Proposal"
    end
end