class EnumKey < ActiveRecord::Base
  has_many :enum_values
  validates_presence_of :code, :description, :key, :type
  validates_uniqueness_of :code, :scope => :type

  def value(arg=Language[I18n.locale].code)
    case arg
    when Symbol
      rval = EnumValue.lookup_code(self.code,arg.id2name)
    when String
      rval = EnumValue.lookup_code(self.code,arg)
    else
      raise TypeError, "#{self.class.name}['#{self.code}'].value(): argument should be a String or a Symbol but got a: #{arg.class.name}"
    end
    rval.nil? ? "" : rval.value 
  end
  
end
