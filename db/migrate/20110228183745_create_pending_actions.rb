class CreatePendingActions < ActiveRecord::Migration
  def self.up
    create_table :pending_actions, :id => false do |t|
      t.string :uuid, :limit => 36, :primary => true
      t.text :action
      t.boolean :status, :default => false, :null => false
      t.integer :user_id
      t.timestamps
    end
    
    remove_column :users, :desired_email
  end

  def self.down
    drop_table :pending_actions
    add_column :users, :desired_email, :string
  end
end
