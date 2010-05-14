module EchoEnumerable
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module InstanceMethods
    
  end
  
  module ClassMethods
    
    
    def enum(name, options = {})      
      config = {:key => name.to_s.singularize << '_id'}
      config.update(options)    
      belongs_to name.to_s.singularize.to_sym, :class_name => "EnumKey", :conditions => {:enum_name => (config[:enum_name] ? config[:enum_name].to_s : name.to_s) }, :foreign_key => config[:key]

      class_eval <<-EOV

        include EchoEnumerable::InstanceMethods

        def self.#{config[:name] ? config[:name].to_s : name.to_s}(code='')
            code.blank? ? EnumKey.by_key.find_all_by_enum_name('#{config[:enum_name] ? config[:enum_name].to_s : name.to_s}') : EnumKey.by_key.find_all_by_enum_name_and_code('#{config[:enum_name] ? config[:enum_name].to_s : name.to_s}',code)  
        end
        
      EOV

    end
  end
end
