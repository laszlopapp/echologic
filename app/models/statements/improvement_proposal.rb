# Specification of an ImprovementProposal

# * ImprovementProposals do mostly refer to the actual document / text of a proposal. They do no represent a different standpoint, but more a different approach to formulate one. 
# * currently an Improvementproposal does always refer to a proposal, and does not expect further children


class ImprovementProposal < StatementNode
  acts_as_incorporable
  
  # methods / settings to overwrite default statement_node behaviour
  validates_parent :Proposal
  expects_children
  
  
  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
