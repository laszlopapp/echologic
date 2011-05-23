
class Improvement < StatementNode
  acts_as_incorporable
  acts_as_alternative :Improvement
  
  has_children_of_types
  has_linkable_types :Improvement, :Proposal, :ProArgument, :ContraArgument

  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
  
  #Overwriting of nested set function (hub's make it impossible to level them right)
  def level; 2; end
end
