# Specification of a Question

# * though the class is called Question, it is commonly refered to as a 'Debate' (in ui, and in concepts).
# * currently a Debate only expects one type of children, Proposals

class Question < StatementNode


  # methods / settings to overwrite default statement_node behaviour

  # the default scope defines basic rules for the sql query sent on this model
  # for questions we do not need to include the echo, and we don't order by supporters count, as they are not supportable
  def self.default_scope
    { :order => %Q[created_at ASC] }
  end

  # Questions are NOT echoable.
  def echoable?
    false
  end
  
  def has_children?
    true
  end
end
