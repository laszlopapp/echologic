class AddDraftingStateToStatementNodeTable < ActiveRecord::Migration
  def self.up
    add_column :statement_nodes, :drafting_state, :string, :limit => 20
  end

  def self.down
    remove_column :statement_nodes, :drafting_state
  end
end
