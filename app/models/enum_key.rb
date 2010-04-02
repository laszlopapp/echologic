class EnumKey < ActiveRecord::Base
  has_many :enum_values
  validates_presence_of :code, :description, :key, :name
  
  #acts_as_list :scope => :subject, :column => 'key'
  
end
