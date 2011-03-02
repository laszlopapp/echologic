class SubscriberData < ActiveRecord::Base

  belongs_to :subscriber, :polymorphic => true
  belongs_to :last_processed_event, :class_name => "Event"

  validates_presence_of :subscriber_id, :subscriber_type
  validates_uniqueness_of :subscriber_id, :scope => :subscriber_type

end
