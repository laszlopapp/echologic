class RemoveDataFromEventDescription < ActiveRecord::Migration
  def self.up
    Event.all.each do |event|
      jevent = JSON.parse(event.event)
      jevent.delete('root_id')
      jevent.delete('root_documents')
      jevent.delete('parent_type')
      event.event = jevent.to_json
      event.save
    end
  end

  def self.down
    Event.all.each do |event|
      s = event.subscribeable
      jevent = JSON.parse(event.event)
      jevent['root_id'] = s.root_id
      jevent['root_documents'] = {}
      s.root.statement_documents.each{|sd|jevent['root_documents'][sd.language_id.to_s] = sd.title}
      jevent['parent_type'] = s.parent_id.nil? ? nil : s.parent.class.name.underscore
      event.event = jevent.to_json
      event.save
    end
  end
end
