module EchoEnumerable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module InstanceMethods

  end

  module ClassMethods

    def enum(name, options = {})
      config = {:key => name.to_s << '_id'}
      config.update(options)
      enum_name = config[:enum_name].to_s

      belongs_to name, :class_name => "EnumKey", :conditions => {:enum_name => enum_name}, :foreign_key => config[:key]

      class_eval <<-EOV
        include EchoEnumerable::InstanceMethods

        def self.#{enum_name}(code='')
          code.blank? ? EnumKey.by_key.find_all_by_enum_name('#{enum_name}') :
          EnumKey.by_key.find_all_by_enum_name_and_code('#{enum_name}',code)
        end
      EOV

    end
  end
end
