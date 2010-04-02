class EnumValue < ActiveRecord::Base
  belongs_to :enum_key
  validates_presence_of :enum_key_id, :value, :language_id
  
  attr :language
  
  named_scope :for_language_id, lambda { |language_id| { :conditions => ['language_id = ?', language_id ], :limit => 1 } }
    
  def self.languages
    EnumKey.find_all_by_name('languages')
  end
  
  def language
    EnumKey.find_by_name_and_key('languages', language_id)
  end
  
end
