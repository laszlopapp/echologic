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
          #has_many :alternative_statements, :through => :hub, :source => :contrary_statements

          
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
            
            def paginated_alternative_statements(page, per_page = nil)
              per_page = alternative_statements.length if per_page.nil? or per_page < 0
              per_page = 1 if per_page.to_i == 0
              
              (hub.nil? ? [] : hub.alternative_statements).paginate(self.class.base_class.default_scope.merge(:page => page, 
                                                                                                              :per_page => per_page))
            end
            
          end # --- class_eval
          has_alternatives args
        end
      end
    end
  end
end
