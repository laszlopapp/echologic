module ActiveRecord
  module Acts
    module Drafter
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_eval do
          include InstanceMethods
        end
          #drafting state. possible values: :tracked, :approved, :incorporated, :passed
      end
      
      module InstanceMethods
        def drafter?
          false
        end
      end
    
      module ClassMethods
        
        def acts_as_drafter(*args)
          state_types = args.to_a.flatten.compact.map(&:to_sym)
    
          write_inheritable_attribute(:state_types, (state_types).uniq)
          class_inheritable_reader(:state_types)
          
          before_validation_on_create :initialize_state
          
          validates_presence_of :drafting_state
          
          state_types.map(&:to_s).each do |state_type|
            state = state_type.to_s
            
            class_eval %(
              def set_#{state}
                self.drafting_state='#{state}'.to_s
                self.save
              end
              
              def is_#{state}?
                drafting_state == '#{state}'.to_s
              end
            )
          end
          
          class_eval <<-RUBY
          
            ####################################
            ###### Static values ###############
            ####################################
      
            # Minimum votes required for an echoable to be taken into account
            def self.min_votes
              5
            end
            
            # Ratio of supporters per visitors required for an echoable to be taken into account
            def self.min_quorum
              50
            end
            
            def drafter?
              true
            end
            
            def min_votes?
              visitor_count > self.class.min_votes
            end
            
            def min_quorum?
              quorum > self.class.min_quorum
            end
            
            # Returns Ratio between number of supporters and number of visitors
            def quorum
              (supporter_count/visitor_count)*100
            end
            
            def initialize_state
              self.drafting_state = 'tracked'
            end
          RUBY
        end
      end
    end
  end
end