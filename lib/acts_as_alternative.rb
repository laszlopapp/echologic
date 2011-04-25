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
