class AddLevelToEvents < ActiveRecord::Migration
  def self.up
    Event.all.each do |event|
      jevent = JSON.parse(event.event)
      if (!jevent['id'].blank?)
        begin
          jevent['level'] = StatementNode.find(jevent['id']).level
          event.event = jevent.to_json
          event.save
        rescue
          event.destroy
        end
      else
        event.destroy
      end
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
