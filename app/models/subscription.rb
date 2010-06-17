class Subscription < ActiveRecord::Base
  belongs_to :subscriber, :polymorphic => true
  belongs_to :subscribeable, :polymorphic => true
  
  validates_presence_of :subscriber_id, :subscribeable_id
  validates_uniqueness_of :subscribeable_id, :scope => :subscriber_id
end
