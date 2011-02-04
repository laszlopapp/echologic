class Argument < StatementNode
  acts_as_double :ProArgument, :ContraArgument

  has_children_of_types

  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
