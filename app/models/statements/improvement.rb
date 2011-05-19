
class Improvement < StatementNode
  acts_as_incorporable

  has_children_of_types
  has_linkable_types :Improvement, :Proposal, :ProArgument, :ContraArgument

  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
