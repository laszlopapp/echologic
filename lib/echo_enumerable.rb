module EchoEnumerable
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module InstanceMethods
    
  end
  
  module ClassMethods
    
    def language_enum
      enum 'languages'
    end
    
    def enum(name, options = {})
      config = {:key => name.singularize << '_id'}
      config.update(options)    
      belongs_to name.singularize.to_sym, :class_name => "EnumKey", :conditions => {:name => name}, :foreign_key => config[:key]

      class_eval <<-EOV

        include EchoEnumerable::InstanceMethods

        def self.#{name}
            EnumKey.find_all_by_name('#{name}')
        end
        
      EOV

    end
  end
end
