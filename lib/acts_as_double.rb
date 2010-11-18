module ActsAsDouble

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    
    def acts_as_double(*args)
      class_eval do
        class << self 
          
          def expected_sub_types
            @@expected_sub_types[self.name] || @@expected_sub_types[self.superclass.name] 
          end
          
          
          def expects_sub_types(klasses)
            @@expected_sub_types ||= { }
            @@expected_sub_types[self.name] ||= []
            @@expected_sub_types[self.name] |= klasses
          end
        
          #overwrite method: look for pro arguments and contra arguments and interpolate them
          def statements_for_parent(parent_id, language_ids = nil, filter_drafting_state = false)
            
            statements = []
            expected_sub_types.each do |type|
              conditions = {:conditions => "type = '#{type.to_s}' and parent_id = #{parent_id}"}
              conditions.merge!({:language_ids => language_ids}) if language_ids
              statements << StatementNode.search_statement_nodes(conditions)  
            end
            statements
          end
          
          def paginate_statements(children, page, per_page)
            children.map{|c|c.paginate(default_scope.merge(:page => page, :per_page => per_page))}
          end
          
          def children_template
            "statements/double/children"
          end
          
          def more_template
            "statements/double/more"
          end
          
          
        end
      end # --- class_eval
      expects_sub_types args
    end
  end
end

