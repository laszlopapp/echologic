class EnumKey < ActiveRecord::Base
  has_many :enum_values
  validates_presence_of :code, :description, :key, :name
  
  #acts_as_list :scope => :subject, :column => 'key'
  
  def self.get_languages
    self.find_all_by_name('languages')
  end
  
  def self.get_language_levels
    self.find_all_by_name('language_levels')
  end
  
  def get_current_enum_value 
    case I18n.locale
      when :en then language = 'english'
      when :de then language = 'german'
    end
    enum_values.for_language_id(EnumKey.first(:conditions => ["code = ?", language]).key).first
  end
  
end
