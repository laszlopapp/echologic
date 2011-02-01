class AddLevelToEvents < ActiveRecord::Migration
  def self.up
    Event.all.each do |event|
      jevent = JSON.parse(event.event)
      jevent['level'] = StatementNode.find(jevent['id']).level
      event.event = jevent.to_json
      event.save
    end
  end

  def self.down
    Event.all.each do |event|
      jevent = JSON.parse(event.event)
      jevent.delete('level')
      event.event = jevent.to_json
      event.save
    end
  end
end
