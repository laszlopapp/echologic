class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer  :subscriber_id
      t.column   :subscriber_type, :string
      t.integer  :subscribeable_id
      t.column   :subscribeable_type, :string
      t.timestamps
    end
    
    add_index :subscriptions, [:subscribeable_id, :subscribeable_type]
    add_index :subscriptions, [:subscriber_id, :subscriber_type]
  end

  def self.down
    drop_table :subscriptions
  end
end
