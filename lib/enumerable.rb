module Enumerable
  def self.included(base)
    base.instance_eval do
      include InstanceMethods
    end
    base.extend(ClassMethods)
  end
    
  module InstanceMethods
   
  end
  
  module ClassMethods
    def enum
      raise 'help'
    end
  end

end
