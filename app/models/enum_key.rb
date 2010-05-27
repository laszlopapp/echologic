class EnumKey < ActiveRecord::Base
  has_many :enum_values
  validates_presence_of :code, :description, :key, :enum_name
  validates_uniqueness_of :code, :scope => :enum_name
  
  #acts_as_list :scope => :subject, :column => 'key'
  
  named_scope :languages, lambda { { :conditions => { :enum_name => 'languages' }, :order => "enum_keys.key DESC" } }
  
  named_scope :language_levels, lambda { { :conditions => { :enum_name => 'language_levels' }, :order => "enum_keys.key ASC" } }
  
  named_scope :by_key, :order => 'enum_keys.key ASC'
  
  def get_current_enum_value    
    enum_values.for_language_id(EnumKey.first(:conditions => ["code = ?", I18n.locale.to_s]).key).first
  end
  
end
