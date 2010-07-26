module Drafteable
  def self.included(base)
    base.instance_eval do
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def acts_as_drafteable(*args)
      state_types = args.to_a.flatten.compact.map(&:to_sym)

      write_inheritable_attribute(:state_types, (state_types).uniq)
      class_inheritable_reader(:state_types)
      
      include InstanceMethods
      state_types.map(&:to_s).each do |state_type|
      state = state_type.to_s
      
      class_eval %(
        def #{state}_children
          instance_variable_get('@#{state}') || instance_variable_set('@#{state}', children.select{|s|s.drafting_state == #{state_type}})
        end
      )
    end
    end
  end

  # Methods mixed in all drafter objects.
  module InstanceMethods
    
    ##################################
    ###### RANKINGS N RELATED ########
    ##################################
    
    # Gets children ordered by supporters number (cacheable)
    def supported_ranking
      instance_variable_get("@supported_ranking") || instance_variable_set("@supported_ranking", fetch_supported_ranking)
    end
    
    # Updates cache of children by supporters
    def update_supported_ranking
      instance_variable_set("@supported_ranking", fetch_supported_ranking)
    end
    
    # Generates SQL query to get children by supporters
    def fetch_supported_ranking
      self.children.by_supporters
    end
  end
end
