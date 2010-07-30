# Specification of an ImprovementProposal

# * ImprovementProposals do mostly refer to the actual document / text of a proposal. They do no represent a different standpoint, but more a different approach to formulate one. 
# * currently an Improvementproposal does always refer to a proposal, and does not expect further children


class ImprovementProposal < StatementNode
  acts_as_state_machine :initial => :tracked, :column => 'drafting_state'
  acts_as_drafter 
  
  
  # These are all of the states for the existing system.
  state :tracked
  state :staged
  state :approved
  state :incorporated
  state :passed

  event :stage do
    transitions :from => :tracked, :to => :staged
  end

  event :approve do
    transitions :from => :tracked, :to => :approved
    transitions :from => :staged, :to => :approved
  end

  event :incorporate do
    transitions :from => :approved, :to => :incorporated
  end

  event :pass do
    transitions :from => :approved, :to => :passed
  end

  
  # methods / settings to overwrite default statement_node behaviour
  validates_parent :Proposal
  expects_children
  
  
  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
