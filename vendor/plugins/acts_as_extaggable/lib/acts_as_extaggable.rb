module ActiveRecord
  module Acts
    module Extaggable
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_eval do
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        def taggable?
          false
        end
      end
      
      module ClassMethods
        
        def acts_as_extaggable(*args)
          tag_types = args.to_a.flatten.compact.map(&:to_sym)

          write_inheritable_attribute(:tag_types, (tag_types).uniq)
          class_inheritable_reader(:tag_types)
          
          class_eval do
            has_many :tao_tags, :as => :tao, :dependent => :destroy, :include => :tag
            has_many :tags, :through => :tao_tags
          end
          
          class_eval <<-RUBY
            ################################
            ###########   TAGS   ###########
            ################################
          
            def taggable?
              true
            end
            
            include ActsAsTaggable::Taggable::Core
          RUBY
        end
      end
    end
  end
end

