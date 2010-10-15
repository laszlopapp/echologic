# Specification of a Proposal

# * Proposals can be either seen as Proposals or as Positions (/Standpoints) as which they are commonly refered to in concepts and ui
# * currently a Position expects only Improvement Proposals as valid children, and only Questions as parents


class Proposal < StatementNode
  acts_as_draftable :tracked, :staged, :approved, :incorporated, :passed
  # methods / settings to overwrite default statement_node behaviour
 
  def taggable?
    false
  end
  
  def has_children?
    true
  end

end
