# Specification of a Question

# * though the class is called Question, it is commonly refered to as a 'Debate' (in ui, and in concepts).
# * currently a Debate only expects one type of children, Proposals

class Question < StatementNode

  # Deletion handling - also delete all FUQs referencing this question
  has_many :follow_up_questions, :foreign_key => 'question_id', :dependent => :destroy

  has_children_of_types [:Proposal,true]
  has_linkable_types :Question

  # methods / settings to overwrite default statement_node behaviour

  # the default scope defines basic rules for the sql query sent on this model
  # for questions we do not need to include the echo, and we don't order by supporters count, as they are not supportable
  def self.default_scope
    { :order => %Q[created_at ASC] }
  end

  def publishable?
    true
  end
  
  def self.publishable?
    true
  end

  #################################################
  # string helpers (acts_as_echoable overwriting) #
  #################################################

  def self.support_tag
    "recommend"
  end

  def self.unsupport_tag
    "unrecommend"
  end
end
