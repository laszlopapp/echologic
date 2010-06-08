class Subscription < ActiveRecord::Base
  belongs_to :subscriber, :class_name => 'User'
  belongs_to :subscribeable, :class_name => 'StatementNode'
  
  validates_uniqueness_of :subscribeable_id, :scope => :subscriber_id
end
