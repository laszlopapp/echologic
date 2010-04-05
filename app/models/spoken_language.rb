class SpokenLanguage < ActiveRecord::Base
  belongs_to :user
  belongs_to :level, :class_name => "EnumKey"
  belongs_to :language, :class_name => "EnumKey"
  
  validates_presence_of :user
  validates_presence_of :level
  validates_presence_of :language
end
