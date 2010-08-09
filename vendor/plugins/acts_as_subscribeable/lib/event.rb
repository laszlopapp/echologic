class Event < ActiveRecord::Base
  belongs_to :subscribeable, :polymorphic => true
  
  
  validates_presence_of :subscribeable_id, :subscribeable_type, :operation
  validates_uniqueness_of :subscribeable_id, :scope => [:subscribeable_type, :operation]
  
  def self.find_tracked_events(subscriber, timespan)
    subscribeable_ids = subscriber.subscribeables.map{|s|[s.id,s.parent_id]}.flatten.compact
    query = sanitize_sql(["SELECT * from events e LEFT JOIN statement_nodes s ON s.id = e.subscribeable_id
                       where s.creator_id != ? and (s.parent_id is null or s.parent_id IN (?)) and
                       e.created_at > ? order by e.event DESC, e.created_at DESC", subscriber.id, 
                       subscribeable_ids, timespan])
    Event.find_by_sql(query)
  end 
end
