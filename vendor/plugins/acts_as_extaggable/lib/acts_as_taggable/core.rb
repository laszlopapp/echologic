module ActsAsTaggable::Taggable
  module Core
    def self.included(base)
      base.send :include, ActsAsTaggable::Taggable::Core::InstanceMethods
      base.extend ActsAsTaggable::Taggable::Core::ClassMethods
      
      base.class_eval do
        attr_writer :custom_contexts
        after_create :save_tags
        after_save :save_tags
      end
      
      base.initialize_acts_as_taggable_on_core
    end
    
    module ClassMethods
      def initialize_acts_as_taggable_on_core
        tag_types.map(&:to_s).each do |tags_type|
          tag_type         = tags_type.to_s.singularize
          context_tao_tags = "#{tag_type}_tao_tags".to_sym
          context_tags = tags_type.to_sym
          
          class_eval do
            has_many context_tao_tags, :class_name => "TaoTag", :include => [:tag], :foreign_key => "tao_id",
                     :conditions => ["tao_tags.context_id = ?", EnumKey.find_by_code(tag_type)]
            has_many context_tags, :through => context_tao_tags, :source => :tag, :class_name => "Tag"
          end
          
          class_eval %(
            def #{tag_type}_tags
              tag_list_on('#{tags_type}')
            end
            
            def #{tag_type}_tags_hash
              tag_list_hash_on('#{tags_type}')
            end
            
            def #{tag_type}_tags=(new_tags)
              set_tag_list_on('#{tags_type}', new_tags)
            end
            
#            def all_#{tag_type}_tags
#            all_tags_list_on('#{tags_type}')
#            end
            )
        end
      end
      
      def acts_as_extaggable(*args)
        super(*args)
        initialize_acts_as_taggable_on_core
      end
      
      # all column names are necessary for PostgreSQL group clause
      def grouped_column_names_for(object)
        object.column_names.map { |column| "#{object.table_name}.#{column}" }.join(", ")
      end
      
      ##
      # Return a scope of objects that are tagged with the specified tags.
      #
      # @param tags The tags that we want to query for
      # @param [Hash] options A hash of options to alter you query:
      # * <tt>:exclude</tt> - if set to true, return objects that are *NOT* tagged with the specified tags
      # * <tt>:any</tt> - if set to true, return objects that are tagged with *ANY* of the specified tags
      # * <tt>:match_all</tt> - if set to true, return objects that are *ONLY* tagged with the specified tags
      #
      # Example:
      # User.tagged_with("awesome", "cool") # Users that are tagged with awesome and cool
      # User.tagged_with("awesome", "cool", :exclude => true) # Users that are not tagged with awesome or cool
      # User.tagged_with("awesome", "cool", :any => true) # Users that are tagged with awesome or cool
      # User.tagged_with("awesome", "cool", :match_all => true) # Users that are tagged with just awesome and cool
      def tagged_with(tags, options = {})
        tag_list = ActsAsTaggable::TagList.from(tags)
        
        return {} if tag_list.empty?
        
        joins = []
        conditions = []
        
        context = options.delete(:on)
        
        if options.delete(:exclude)
          tags_conditions = tag_list.map { |t| sanitize_sql(["#{Tag.table_name}.value LIKE ?", t]) }.join(" OR ")
          conditions << "#{table_name}.#{primary_key} NOT IN (SELECT #{TaoTag.table_name}.tao_id FROM #{TaoTag.table_name} JOIN #{Tag.table_name} ON #{TaoTag.table_name}.tag_id = #{Tag.table_name}.id AND (#{tags_conditions}) WHERE #{TaoTag.table_name}.tao_type = #{quote_value(base_class.name)})"
          
        elsif options.delete(:any)
          tags_conditions = tag_list.map { |t| sanitize_sql(["#{Tag.table_name}.value LIKE ?", t]) }.join(" OR ")
          conditions << "#{table_name}.#{primary_key} IN (SELECT #{TaoTag.table_name}.tao_id FROM #{TaoTag.table_name} JOIN #{Tag.table_name} ON #{TaoTag.table_name}.tag_id = #{Tag.table_name}.id AND (#{tags_conditions}) WHERE #{TaoTag.table_name}.tao_type = #{quote_value(base_class.name)})"
          
        else
          tags = Tag.named_any(tag_list)
          return scoped(:conditions => "1 = 0") unless tags.length == tag_list.length
          
          tags.each do |tag|
            safe_tag = tag.value.gsub(/[^a-zA-Z0-9]/, '')
            prefix = "#{safe_tag}_#{rand(1024)}"
            
            tao_tags_alias = "#{undecorated_table_name}_tao_tags_#{prefix}"
            
            tagging_join = "JOIN #{TaoTag.table_name} #{tao_tags_alias}" +
                            " ON #{tao_tags_alias}.tao_id = #{table_name}.#{primary_key}" +
                            " AND #{tao_tags_alias}.tao_type = #{quote_value(base_class.name)}" +
                            " AND #{tao_tags_alias}.tag_id = #{tag.id}"
            tagging_join << " AND " + sanitize_sql(["#{tao_tags_alias}.context_id = ?", EnumKey.find_by_code(context.to_s.singularize)]) if context
            
            joins << tagging_join
          end
        end
        
        tao_tags_alias, tags_alias = "#{undecorated_table_name}_tao_tags_group", "#{undecorated_table_name}_tags_group"
        
        if options.delete(:match_all)
          joins << "LEFT OUTER JOIN #{TaoTag.table_name} #{tao_tags_alias}" +
                   " ON #{tao_tags_alias}.tao_id = #{table_name}.#{primary_key}" +
                   " AND #{tao_tags_alias}.tao_type = #{quote_value(base_class.name)}"
          
          
          group_columns = Tag.using_postgresql? ? grouped_column_names_for(self) : "#{table_name}.#{primary_key}"
          group = "#{group_columns} HAVING COUNT(#{tao_tags_alias}.tao_id) = #{tags.size}"
        end
        
        
        scoped(:joins => joins.join(" "),
               :group => group,
               :conditions => conditions.join(" AND "),
               :order => options[:order],
               :readonly => false)
      end
    end
    
    module InstanceMethods
      # all column names are necessary for PostgreSQL group clause
      def grouped_column_names_for(object)
        self.class.grouped_column_names_for(object)
      end
      
      def custom_contexts
        @custom_contexts ||= []
      end
      
      
      def add_custom_context(value)
        custom_contexts << value.to_s unless custom_contexts.include?(value.to_s) or self.class.tag_types.map(&:to_s).include?(value.to_s)
      end
      
      def cached_tag_list_on(context)
        self["cached_#{context.to_s.singularize}_list"]
      end
      
      def tag_list_cache_set_on(context)
        variable_name = "@#{context.to_s.singularize}_list"
        !instance_variable_get(variable_name).nil?
      end
      
      def tag_list_cache_on(context)
        context_sing = context.to_s.singularize
        variable_name = "@#{context_sing}_list"
        instance_variable_get(variable_name) || instance_variable_set(variable_name, ActsAsTaggable::TagList.new(tags_on(context_sing).map(&:value)))
      end
      
      def tag_list_hash_cache_on(context)
        context_sing = context.to_s.singularize
        variable_name = "@#{context_sing}_list_hash"
        hash = {}
        return instance_variable_get(variable_name) if instance_variable_get(variable_name)
        tags_on(context_sing).each{|tag| hash[tag.id]=tag.value}
        instance_variable_set(variable_name,hash)
        return instance_variable_get(variable_name)
      end
      
      def tag_list_on(context)
        add_custom_context(context)
        tag_list_cache_on(context)
      end
      
      def tag_list_hash_on(context)
        add_custom_context(context)
        tag_list_hash_cache_on(context)
      end
      
      def all_tags_list_on(context)
        context_sing = context.to_s.singularize
        variable_name = "@all_#{context_sing}_list"
        return instance_variable_get(variable_name) if instance_variable_get(variable_name)
        
        instance_variable_set(variable_name, ActsAsTaggable::TagList.new(all_tags_on(context_sing).map(&:value)).freeze)
      end
      
      ##
      # Returns all tags of a given context
      def all_tags_on(context)
        tag_table_name = Tag.table_name
        tagging_table_name = TaoTag.table_name
        
        opts = ["#{tagging_table_name}.context_id = ?", EnumKey.find_by_code(context.to_s)]
        scope = tags.where(opts)
        
        if Tag.using_postgresql?
          group_columns = grouped_column_names_for(Tag)
          scope = scope.order("max(#{tagging_table_name}.created_at)").group(group_columns)
        else
          scope = scope.group("#{Tag.table_name}.#{Tag.primary_key}")
        end
        
        scope.all
      end
      
      ##
      # Returns all tags that are not owned of a given context
      def tags_on(context)
        tags.where(["#{TaoTag.table_name}.context_id = ?", EnumKey.find_by_code(context)]).all
      end
      
      def set_tag_list_on(context, new_list)
        add_custom_context(context)
        
        variable_name = "@#{context.to_s.singularize}_list"
        instance_variable_set(variable_name, ActsAsTaggable::TagList.from(new_list))
        instance_variable_set("@#{context.to_s.singularize}_list_hash", nil)
      end
      
      def tagging_contexts
        custom_contexts + self.class.tag_types.map(&:to_s)
      end
      
      def reload(*args)
        self.class.tag_types.each do |context|
          instance_variable_set("@#{context.to_s.singularize}_list", nil)
          instance_variable_set("@#{context.to_s.singularize}_list_hash", nil)
          instance_variable_set("@all_#{context.to_s.singularize}_list", nil)
        end
        
        super(*args)
      end
      
      def save_tags
        tagging_contexts.each do |context|
          context_name = context.to_s.singularize
          next unless tag_list_cache_set_on(context)
          
          tag_list = tag_list_cache_on(context).uniq
          
          # Find existing tags or create non-existing tags:
          tag_list = Tag.find_or_create_all_with_values_like(tag_list)
          
          current_tags = tags_on(context_name)
          old_tags = current_tags - tag_list 
          new_tags = tag_list  - current_tags 
          
          # Find tao_tags to remove:
          old_tao_tags = tao_tags.where(:context_id => EnumKey.find_by_code(context_name), :tag_id => old_tags).all
          
          if old_tao_tags.present?
            # Destroy old tao_tags:
            TaoTag.destroy_all :id => old_tao_tags.map(&:id)
          end
          
          # Create new tao_tags:
          new_tags.each do |tag|
            tao_tags.create!(:tag => tag, :context_id => EnumKey.find_by_code(context_name).id, :tao => self, :tao_type => self.class.name)
          end
        end
        
        true
      end
    end
  end
end