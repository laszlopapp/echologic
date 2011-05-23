class ProArgument < Argument
  acts_as_alternative :ContraArgument
  
  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
