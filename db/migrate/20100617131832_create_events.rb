class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :event, :text
      t.integer :subscribeable_id
      t.column :subscribeable_type, :string
      t.column :operation, :string
      t.datetime :created_at
    end
    
    add_index :events, [:subscribeable_id, :subscribeable_type, :created_at]
  end

  def self.down
    remove_table :events
  end
end
