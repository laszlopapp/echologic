class FollowUpQuestion < StatementNode 
  
  belongs_to :discussion, :dependent => :destroy #is it dependent?
  
  delegate :level, :topic_tags, :topic_tags=, :taggable?, :echoable?, :statement, :statement=, :statement_id, 
           :statement_documents, :supporter_count, :ratio, :editorial_state_id, :editorial_state_id=, 
           :publishable?, :published, :publish, :locked_at, :supported?, :taggable?, :creator_id=, :creator_id, 
           :creator, :author_support, :ancestors, :to => :discussion
  
  before_save :save_discussion
  
  
  def save_discussion
    discussion.save
  end
  
  expects_children_types
  
  class << self
    def new_instance(attributes = nil)
      parent = attributes ? attributes.delete(:parent_id) : nil 
      discussion = Discussion.new(attributes)
      self.new({:parent_id => parent, :discussion => discussion})
    end
    
    def join_clause
      <<-END
        select distinct n.*
        from
          statement_nodes n
          LEFT JOIN statement_nodes n2       ON n.discussion_id = n2.id
          LEFT JOIN statement_documents d    ON n2.statement_id = d.statement_id
          LEFT JOIN tao_tags tt              ON (tt.tao_id = n2.id and tt.tao_type = 'StatementNode')
          LEFT JOIN tags t                   ON tt.tag_id = t.id
          LEFT JOIN echos e                  ON n2.echo_id = e.id
        where
      END
    end
  end
  
end