class EnumValue < ActiveRecord::Base
  has_many :multilingual_resources
  validates_presence_of :code, :description, :key, :subject
end
