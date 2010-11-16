class Argument < StatementNode

  expects_children_types
  
  # Overwriting the acts_as_taggable function saying this object is not taggable anymore
  def taggable?
    false
  end
  
  class << self
    
    #overwrite method: look for pro arguments and contra arguments and interpolate them
    def statements_for_parent(parent_id, language_ids = nil, filter_drafting_state = false)
      # get pro arguments
      conditions = {:conditions => "type = 'ProArgument' and parent_id = #{parent_id}"}
      conditions.merge!({:language_ids => language_ids}) if language_ids
      pro_arguments = self.superclass.search_statement_nodes(conditions)
      
      # get contra arguments
      conditions = {:conditions => "type = 'ContraArgument' and parent_id = #{parent_id}"}
      conditions.merge!({:language_ids => language_ids}) if language_ids
      contra_arguments = self.superclass.search_statement_nodes(conditions)
      
      [pro_arguments, contra_arguments]
    end
    
  end
  
end
