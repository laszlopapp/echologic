module ActiveRecord
  module Acts
    module Incorporable
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_eval do
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        def incorporable?
          false
        end
      end
    
      module ClassMethods
        
        def acts_as_incorporable(*args)
          
          class_eval do
            # Acts as State Machine plugin
            acts_as_state_machine :initial => :tracked, :column => 'drafting_state'
            
            # These are all of the states for the existing system.
            state :tracked
            state :ready
            state :staged
            state :approved
            state :incorporated
          
            event :track do
              transitions :from => :ready, :to => :tracked
              transitions :from => :staged, :to => :tracked
              transitions :from => :approved, :to => :tracked
            end
          
            event :ready do
              transitions :from => :tracked, :to => :staged
            end
            event :stage do
              transitions :from => :ready, :to => :staged
              transitions :from => :approved, :to => :staged
            end
            event :incorporate do
              transitions :from => :approved, :to => :incorporated
            end
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
              (supporter_count/parent.supporter_count)*100
            end
          RUBY
        end
      end
    end
  end
end