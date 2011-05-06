class AddPrivateTagsToEventJson < ActiveRecord::Migration
  def self.up
    Event.all.each do |event|
      e = JSON.parse(event.event)
      e['private_tags'] = []
      event.event = e.to_json
      event.save
    end
  end

  def self.down
    Event.all.each do |event|
      e = JSON.parse(event.event)
      e.delete(:private_tags)
      event.event = e.to_json
      event.save
    end
  end
end
