class MultilingualResource < ActiveRecord::Base
  belongs_to :enum_value
  validates_presence_of :context, :enum_value_id, :value, :language_id
end
