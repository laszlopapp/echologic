module Drafter
  def self.included(base)
    base.instance_eval do
      base.extend(ClassMethods)
      #drafting state. possible values: :tracked, :approved, :incorporated, :passed
      
      
      include InstanceMethods
    end
  end

  module ClassMethods
    
    def acts_as_drafter(*args)
      state_types = args.to_a.flatten.compact.map(&:to_sym)

      write_inheritable_attribute(:state_types, (state_types).uniq)
      class_inheritable_reader(:state_types)
      
      
      include InstanceMethods
      state_types.map(&:to_s).each do |state_type|
        state = state_type.to_s
        
        class_eval %(
          def set_#{state}
            drafting_state=#{state_type}
          end
          
          def is_#{state}?
            drafting_state == #{state_type}
          end
        )
      end
    end
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
  end

  # Methods mixed in all drafter objects.
  module InstanceMethods
    
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
    
    # State getter
    def drafting_state
      instance_variable_get("@drafting_state") || instance_variable_set("@drafting_state", :tracked)
    end
    
    # State setter
    def drafting_state=(value)
      instance_variable_set("@drafting_state", value)
    end
  end
end
