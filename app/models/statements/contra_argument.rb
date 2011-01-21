class ContraArgument < Argument
  
  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
