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
      belongs_to name.to_s.singularize.to_sym, :class_name => "EnumKey", :conditions => {:name => (config[:name] ? config[:name].to_s : name.to_s) }, :foreign_key => config[:key]

      class_eval <<-EOV

        include EchoEnumerable::InstanceMethods

        def self.#{name.to_s}(code='')
            code.blank? ? EnumKey.by_key.find_all_by_name('#{name.to_s}') : EnumKey.find_all_by_name_and_code('#{name.to_s}',code)  
        end
        
      EOV

    end
  end
end
