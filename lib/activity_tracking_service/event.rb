class Event < ActiveRecord::Base
  belongs_to :subscribeable, :polymorphic => true

  # FIXME: make only one SQL and join for subscribable ids instead of using parent_id IN (?) !!!!
  def self.find_tracked_events(subscriber)
    select_clause = <<-END
      select distinct e.* from events e
        where e.subscribeable_id is null AND e.created_at > ? AND e.id > ?
      UNION
      select distinct e.* from events e
        LEFT JOIN subscriptions sb ON (e.subscribeable_id = sb.subscribeable_id)
        where sb.subscriber_id = ? AND e.created_at > ? AND e.id > ?
      ORDER by created_at DESC
    END
    query = sanitize_sql([select_clause,
                          1.month.ago.utc,
                          subscriber.last_processed_event_id,
                          subscriber.id,
                          1.month.ago.utc,
                          subscriber.last_processed_event_id])
    Event.find_by_sql(query)
  end
end
