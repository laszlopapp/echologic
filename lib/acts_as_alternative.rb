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
          
          has_many :alternative_statements, 
                   :finder_sql => 'SELECT DISTINCT * FROM statement_nodes s ' +
                                  'LEFT OUTER JOIN statement_nodes hubs ON s.parent_id = hubs.id AND hubs.type = \'CasHub\' ' +
                                  'WHERE s.parent_id is not null AND s.question_id is null AND s.parent_id = #{hub ? hub.id : -1} AND s.id != #{id}',
                   :class_name => 'StatementNode'
          
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
            end
          end # --- class_eval
          has_alternatives args
        end
      end
    end
  end
end
