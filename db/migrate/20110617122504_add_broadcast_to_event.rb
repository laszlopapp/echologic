class AddBroadcastToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :broadcast, :boolean, :default => false
    Event.all(:conditions => "operation = 'created'").each do |event|
      e = JSON.parse(event.event)
      if e['level'] == 0
        event.broadcast = true
        event.save
      end
    end
  end

  def self.down
    remove_column :events, :broadcast
  end
end
