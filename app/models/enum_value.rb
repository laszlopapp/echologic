class EnumValue < ActiveRecord::Base
  
  enum :languages
  
  belongs_to :enum_key
  validates_presence_of :enum_key_id, :value, :language_id
  
  named_scope :for_language_id, lambda { |language_id| { :conditions => ['language_id = ?', language_id ], :limit => 1 } }
    
end
