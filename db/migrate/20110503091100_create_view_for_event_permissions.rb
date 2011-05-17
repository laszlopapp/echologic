class CreateViewForEventPermissions < ActiveRecord::Migration
  def self.up
    create_view :event_permissions,
    "SELECT DISTINCT e.id AS event_id, perm.statement_id AS closed_statement, perm.user_id AS granted_user_id
     FROM events e
     LEFT JOIN statement_nodes s_nodes   ON e.subscribeable_id = s_nodes.id AND e.subscribeable_type = 'StatementNode'
     LEFT JOIN statement_nodes roots     ON roots.id = s_nodes.root_id
     LEFT JOIN statements s              ON s.id = roots.statement_id
     LEFT JOIN statement_permissions perm ON perm.statement_id = s.id;" do |t|
      t.column :event_id
      t.column :closed_statement
      t.column :granted_user_id
    end

    Event.all.each do |event|
      e = JSON.parse(event.event)
      e.delete(:private_tags)
      event.event = e.to_json
      event.save
    end
  end

  def self.down
    drop_view :event_permissions
    Event.all.each do |event|
      e = JSON.parse(event.event)
      e['private_tags'] = []
      event.event = e.to_json
      event.save
    end
  end
end
