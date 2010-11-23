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
          def statements_for_parent(parent_id, language_ids = nil, filter_drafting_state = false, for_session = false)
            
            conditions = {:conditions => "type = '#{self.name.to_s}' and parent_id = #{parent_id}"}
            conditions.merge!({:language_ids => language_ids}) if language_ids
            conditions.merge!({:drafting_states => %w(tracked ready staged)}) if filter_drafting_state
            
            statements = []
            expected_sub_types.each do |type|
              statements << StatementNode.search_statement_nodes(conditions)
            end
            if for_session
              statements.map!{|s|s.map(&:id)}
              expected_sub_types.each_with_index{|type, index| statements[index] += ["add/#{type.to_s.underscore}"]}
              statements = session_ordering(statements)
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
          
          def session_ordering(list)
            min = list.map(&:length).min
            ordered_list = list.map{|s|s.slice(0,min)}.transpose + list.map{|s|s[min..-1]}
            ordered_list.flatten
          end
        end
        
        # Collects a filtered list of all siblings statements
        def siblings_to_session(language_ids = nil, type = self.class.to_s)
          siblings = []
          sibling_statements(language_ids, type).map{|s|s.map(&:id)}.each_with_index do |s, index|
            siblings << s + ["add/#{self.class.expected_sub_types[index].to_s.underscore}"]
          end
          #order them properly, as you want them to be navigated
          ordered_siblings = self.class.session_ordering(siblings)
          ordered_siblings
        end
      end # --- class_eval
      expects_sub_types args
    end
  end
end

