
class Improvement < StatementNode
  acts_as_incorporable
  acts_as_alternative :Improvement
  
  has_children_of_types

  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
end
