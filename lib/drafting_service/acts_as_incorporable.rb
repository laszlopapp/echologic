module ActiveRecord
  module Acts
    module Incorporable
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_eval do
          include InstanceMethods
        end
          #drafting state. possible values: :tracked, :approved, :incorporated, :passed
      end
      
      module InstanceMethods
        def incorporable?
          false
        end
      end
    
      module ClassMethods
        
        def acts_as_incorporable(*args)
          
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
            
            def incorporable?
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
          RUBY
        end
      end
    end
  end
end