module ActsAsDouble

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def acts_as_double(*args)
      class_eval do
        class << self

          def expected_sub_types
            @@expected_sub_types[self.name] || @@expected_sub_types[self.superclass.name]
          end


          def expects_sub_types(klasses)
            @@expected_sub_types ||= { }
            @@expected_sub_types[self.name] ||= []
            @@expected_sub_types[self.name] |= klasses
          end

          def statements_for_parent(parent_id, language_ids = nil, filter_drafting_state = false, for_session = false)
            statements = []
            expected_sub_types.each do |type|
              statements << type.to_s.constantize.do_statements_for_parent(parent_id,
                                                                           language_ids,
                                                                           filter_drafting_state,
                                                                           for_session)
            end
            statements.flatten if for_session
          end

          def paginate_statements(children, page, per_page)
            children.map{|c|c.paginate(default_scope.merge(:page => page, :per_page => per_page))}
          end

          def children_template
            "statements/double/children"
          end

          def more_template
            "statements/double/more"
          end

          def merge_statement_lists(list)
            min = list.map(&:length).min
            ordered_list = list.map{|s|s.slice(0,min)}.transpose + list.map{|s|s[min..-1]}
            ordered_list.flatten
          end
        end

        # Collects a filtered list of all siblings statements
        def siblings_to_session(language_ids = nil, type = self.class.to_s)
          siblings = []
          sibling_statements(language_ids, type).map{|s|s.map(&:id)}.each_with_index do |s, index|
            siblings << s + ["/#{self.parent_id.nil? ? '' : "#{self.parent.id_as_parent}/"}add/#{self.class.expected_sub_types[index].to_s.underscore}"]
          end
          #order them properly, as you want them to be navigated
          ordered_siblings = self.class.merge_statement_lists(siblings)
          ordered_siblings
        end
      end # --- class_eval

      expects_sub_types args
    end
  end
end

