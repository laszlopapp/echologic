class ChangeStatementNodeStateIdToEditorialStateId < ActiveRecord::Migration
  def self.up
    rename_column :statement_nodes, :state_id, :editorial_state_id
  end

  def self.down
    rename_column :statement_nodes, :editorial_state_id, :state_id
  end
end
