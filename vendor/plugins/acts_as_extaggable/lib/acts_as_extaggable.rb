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
        
        def taggable?
          false
        end

        def acts_as_extaggable(*args)
          tag_types = args.to_a.flatten.compact.map(&:to_sym)

          write_inheritable_attribute(:tag_types, (tag_types).uniq)
          class_inheritable_reader(:tag_types)

          class_eval do
            has_many :tao_tags, :as => :tao, :dependent => :destroy, :include => :tag
            has_many :tags, :through => :tao_tags
          end

          class_eval do
            ################################
            ###########   TAGS   ###########
            ################################

            def taggable?
              true
            end

            def self.taggable?
              true
            end

            #
            # SQL Queries Helpers
            #
            def self.extaggable_joins_clause(attribute = "#{self.table_name}.id")
              "LEFT JOIN #{TaoTag.table_name} ON (#{TaoTag.table_name}.tao_id = #{attribute} and #{TaoTag.table_name}.tao_type = '#{self.name}') " +
              "LEFT JOIN #{Tag.table_name} ON #{TaoTag.table_name}.tag_id = #{Tag.table_name}.id "
            end

            def self.extaggable_conditions_for_term(term, attribute="#{Tag.table_name}.value", word_length=3)
              (term.length > word_length ? sanitize_sql(["#{attribute} LIKE ?","%#{term}%"]) : sanitize_sql(["#{attribute} = ?",term]))
            end

            def self.extaggable_filter_by_type(type)
              sanitize_sql(["#{TaoTag.table_name}.context_id = ?", type])
            end

            include ActsAsTaggable::Taggable::Core
          end
        end
      end
    end
  end
end

