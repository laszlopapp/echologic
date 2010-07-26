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
      
      include InstanceMethods
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
