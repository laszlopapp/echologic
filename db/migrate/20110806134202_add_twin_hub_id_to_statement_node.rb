class AddTwinHubIdToStatementNode < ActiveRecord::Migration
  def self.up
    add_column :statement_nodes, :twin_hub_id, :integer
  end

  def self.down
    remove_column :statement_nodes, :twin_hub_id
  end
end
