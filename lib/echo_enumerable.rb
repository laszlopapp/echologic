module EchoEnumerable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module InstanceMethods
  end

  module ClassMethods

    def enum(name, options = {})
      field_name = name.to_s
      config = {:key => name.to_s << '_id'}
      config.update(options)
      enum_name = config[:enum_name].to_s

      belongs_to name,
                 :class_name => "EnumKey",
                 :conditions => {:enum_name => enum_name},
                 :foreign_key => config[:key]

      class_eval <<-EOV
        include EchoEnumerable::InstanceMethods

        # Returns all EnumKeys for the given enum name.
        def self.#{enum_name}(code='')
          if code.blank?
            EnumKey.by_key.find_all_by_enum_name('#{enum_name}')
          else
            list = EnumKey.by_key.find_all_by_enum_name_and_code('#{enum_name}',code)
            list.empty? ? nil : list.first
          end
        end

        # Returns the primary keys of all EnumKeys belonging to the given enum name.
        # TODO: should be decrecated - EnumKey.key should be used to reference enums instead of primary keys!
        def self.#{field_name}_ids()
          EnumKey.find_all_by_enum_name('#{enum_name}').map(&:id)
        end

        # Returns the unique keys of all EnumKeys belonging to the given enum name.
        def self.#{field_name}_keys()
          EnumKey.find_all_by_enum_name('#{enum_name}').map(&:key)
        end

        # Returns the unique human readable codes of all EnumKeys belonging to the given enum name.
        def self.#{field_name}_codes()
          EnumKey.find_all_by_enum_name('#{enum_name}').map(&:code)
        end

      EOV

    end
  end
end
