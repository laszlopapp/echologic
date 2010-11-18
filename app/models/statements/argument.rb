class Argument < StatementNode
  acts_as_double :ProArgument, :ContraArgument

  expects_children_types
  
  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
