class CreateDraftingInfos < ActiveRecord::Migration
  def self.up
    create_table :drafting_infos do |t|
      t.integer :statement_node_id
      t.datetime :state_since, :default => Time.now
      t.integer :times_passed, :default => 0
    end
  end

  def self.down
    drop_table :drafting_infos
  end
end
