class FollowUpQuestion < StatementNode

  belongs_to :question, :dependent => :destroy #is it dependent?

  delegate :level, :ancestors, :topic_tags, :topic_tags=, :tags, :taggable?, :echoable?, :editorial_state_id, 
           :editorial_state_id=, :publishable?, :published, :locked_at, :supported?, :taggable?, :creator_id=, 
           :creator_id, :creator, :author_support, :ancestors, :target_id, :to => :question

  validates_associated :question
  
  def target_statement
    self.question
  end
  
  def set_statement(attrs={})
    self.statement = self.question.statement = Statement.new(attrs)
  end
  
  #################################################
  # string helpers (acts_as_echoable overwriting) #
  #################################################
  
  



  class << self
    def children_types(visibility = false, default = true, expand = false)
      Question.children_types(visibility, default, expand)
    end

    def new_instance(attributes = nil)
      parent = attributes ? attributes.delete(:parent_id) : nil
      root = attributes.delete(:root_id)
      question = Question.new_instance(attributes)
      self.new({:parent_id => parent, :root_id => root, :question => question, :echo => question.echo, :statement => question.statement})
    end

    # helper function to differentiate this model as a level 0 model
    def is_top_statement?
      true
    end
    
    def children_conditions(parent_id)
      parent = StatementNode.find(parent_id)
      sanitize_sql(["statement_nodes.type = ? AND statement_nodes.root_id = ? AND statement_nodes.lft >= ? AND statement_nodes.rgt <= ? ", self.name, parent.root_id, parent.lft, parent.rgt])
    end
    
    #################################################
    # string helpers (acts_as_echoable overwriting) #
    #################################################
    
    def support_tag
      "recommend"
    end
    
    def unsupport_tag
      "unrecommend"
    end
  end

end