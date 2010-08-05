class Event < ActiveRecord::Base
  belongs_to :subscribeable, :polymorphic => true
  
  
  validates_presence_of :subscribeable_id, :subscribeable_type, :operation
  validates_uniqueness_of :subscribeable_id, :scope => [:subscribeable_type, :operation]
end
