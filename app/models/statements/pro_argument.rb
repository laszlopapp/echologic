class ProArgument < Argument
  acts_as_alternative :ContraArgument
  has_linkable_types :Proposal, :ProArgument, :ContraArgument

  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
  
  def self.taggable?
    false
  end
end
