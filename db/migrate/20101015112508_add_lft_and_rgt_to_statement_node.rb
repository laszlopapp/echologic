class AddLftAndRgtToStatementNode < ActiveRecord::Migration
  def self.up
    add_column :statement_nodes, :lft, :integer
    add_column :statement_nodes, :rgt, :integer
    
    StatementNode.rebuild!
  end

  def self.down
    remove_column :statement_nodes, :lft
    remove_column :statement_nodes, :rgt
  end
end
