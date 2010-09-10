class EnumKey < ActiveRecord::Base
  has_many :enum_values
  validates_presence_of :code, :description, :key, :type
  validates_uniqueness_of :code, :scope => :type
  
 
#  def get_current_enum_value    
#    enum_values.for_key(Language[I18n.locale].key).first
#  end
  
end
