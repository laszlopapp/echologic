module ActiveRecord
  module Acts
    module Alternative

      def self.included(base)
        base.extend(ClassMethods)
      end
    
      module ClassMethods
    
        def has_alternatives?
          false
        end
    
        def acts_as_alternative(*args)
          args.flatten! if args
          args.compact! if args
          
          belongs_to :hub, :class_name => 'CasHub', :foreign_key => 'parent_id' 
          
          #TODO: WHEN RAILS ALLOWS THIS TO WORK, PLEASE ACTIVATE THIS RELSHIP: currently fails because the has many
          #      through joins the statement nodes table with itself (correct) without alias (false!). 
          #      when all goes well, please update the paginated alternative statements function
          #
          #has_many :alternatives, :through => :hub, :source => :contrary_statements

          
          class_eval do
            class << self
              
              def has_alternatives(*klasses)
                @@alternative_types ||= { }
                @@alternative_types[self.name] ||= []
                @@alternative_types[self.name] |= klasses
              end
              
              def has_alternatives?
                true
              end
              
              # TODO: When statement allows more alternative types, change this here
              def alternative
                @@alternative_types[self.name].first
              end
              
              def alternative_conditions(opts)
                sanitize_sql([" AND statement_nodes.id IN (?) ", opts[:alternative_ids]])
              end
            end
            
            def alternatives
              hub.nil? ? [] : hub.alternatives - [self]
            end
            
            def paginated_alternatives(page, per_page = nil,opts={})
              alternative_statements = hub.nil? ? [] : hub.child_statements(opts.merge({:type => self.class.alternative, 
                                                                                        :alternative_ids => alternatives.map(&:id)}))
              
              per_page = alternative_statements.length if per_page.nil? or per_page < 0
              per_page = 1 if per_page.to_i == 0
              alternative_statements.paginate(self.class.base_class.default_scope.merge(:page => page, 
                                                                                        :per_page => per_page))
            end
            
            # function called on the alternative creation process
            def move_to_alternatives_hub(node_id)
              alternative = StatementNode.find(node_id)
              if alternative
                hub = alternative.hub
                if hub.nil?
                  hub = CasHub.create(:root_id =>alternative.root_id, :parent_id => alternative.parent_id)
                  alternative.move_to_child_of hub
                end
                self.parent_id = hub.id
              end
            end
          end # --- class_eval
          has_alternatives args
        end
      end
    end
  end
end
