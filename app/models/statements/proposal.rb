# Specification of a Proposal

# * Proposals can be either seen as Proposals or as Positions (/Standpoints) as which they are commonly refered to in concepts and ui
# * currently a Position expects only Improvement Proposals as valid children, and only Discussions as parents


class Proposal < StatementNode
  acts_as_draftable :tracked, :staged, :approved, :incorporated, :passed
 
  expects_children_types [:ImprovementProposal,true],[:Argument,false]
 
  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
