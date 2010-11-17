class Argument < Double

  expects_sub_types :ProArgument, :ContraArgument

  expects_children_types
  
  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
