module ActiveRecord
  module Acts
    module Drafteable
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_eval do
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        def drafteable?
          false
        end
      end
    
      module ClassMethods
        def acts_as_drafteable(*args)
          state_types = args.to_a.flatten.compact.map(&:to_sym)
    
          write_inheritable_attribute(:state_types, (state_types).uniq)
          class_inheritable_reader(:state_types)
          
          class_eval do
            after_create :check_incorporate
          end
          
          state_types.map(&:to_s).each do |state_type|
            state = state_type.to_s
            
            class_eval %(
              def #{state}_children
                children.select{|s|s.drafting_state == '#{state}'}
              end
            )
          end
          
          class_eval <<-RUBY
          
            def drafteable?
              true
            end
      
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
            
            def check_incorporate
              Echo.instance.incorporated(self) if self.action.code.eql?('incorporate')
            end
          RUBY
        end
      end
    end
  end
end