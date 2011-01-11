class FollowUpQuestion < StatementNode

  belongs_to :question, :dependent => :destroy #is it dependent?

  delegate :level, :ancestors, :topic_tags, :topic_tags=, :taggable?, :echoable?, :editorial_state_id, :editorial_state_id=,
           :publishable?, :published, :publish, :locked_at, :supported?, :taggable?, :creator_id=, :creator_id,
           :creator, :author_support, :ancestors, :target_id, :to => :question

  validates_associated :question
  
  def target_statement
    self.question
  end
  
  def set_statement(attrs)
    self.statement = self.question.statement = Statement.new(attrs)
  end

  class << self
    def children_types(children_visibility = false, default = true, expand = false)
      Question.children_types(children_visibility, default, expand)
    end

    def new_instance(attributes = nil)
      parent = attributes ? attributes.delete(:parent_id) : nil
      question = Question.new(attributes)
      self.new({:parent_id => parent, :question => question, :echo => question.echo})
    end

    # helper function to differentiate this model as a level 0 model
    def is_top_statement?
      true
    end

  end

end