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
            end
            
            
            def paginated_alternatives(page, per_page = nil)
              per_page = alternatives.length if per_page.nil? or per_page < 0
              per_page = 1 if per_page.to_i == 0
              
              (hub.nil? ? [] : hub.alternatives).paginate(self.class.base_class.default_scope.merge(:page => page, 
                                                                                                              :per_page => per_page))
            end
            
          end # --- class_eval
          has_alternatives args
        end
      end
    end
  end
end
