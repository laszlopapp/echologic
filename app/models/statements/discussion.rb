# Specification of a Discussion

# * though the class is called Discussion, it is commonly refered to as a 'Debate' (in ui, and in concepts).
# * currently a Debate only expects one type of children, Proposals

class Discussion < StatementNode

  has_children_of_types [:Proposal,true]

  # methods / settings to overwrite default statement_node behaviour

  # the default scope defines basic rules for the sql query sent on this model
  # for discussions we do not need to include the echo, and we don't order by supporters count, as they are not supportable
  def self.default_scope
    { :order => %Q[created_at ASC] }
  end

  def publishable?
    true
  end

  # Discussions are NOT echoable.
  def echoable?
    false
  end
end
