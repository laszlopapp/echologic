class CreateSubscriberDatas < ActiveRecord::Migration
  def self.up
    create_table :subscriber_datas do |t|
      t.integer :subscriber_id
      t.string  :subscriber_type
      t.integer :last_processed_event_id
    end

    last_event = Event.last
    User.all.each do |user|
      SubscriberData.create :subscriber => user, 
                            :last_processed_event => last_event
    end

  end

  def self.down
    drop_table :subscriber_datas
  end
end
