class DiscussAlternativesQuestion < FollowUpQuestion
  has_linkable_types

  class << self
    
    def new_instance(attributes = nil)
      parent = attributes ? attributes.delete(:parent_id) : nil
      root = attributes.delete(:root_id)
      statement = Statement.find(attributes.delete(:statement_id)) if !attributes[:statement_id].blank?
      question = statement.nil? ? Question.new_instance(attributes) : statement.statement_nodes.all(:conditions => "type = 'Question'").first
      self.new({:parent_id => parent,
                :root_id => root,
                :question => question,
                :creator => question.creator,
                :echo => question.echo,
                :statement => question.statement})
    end

  
  end
end