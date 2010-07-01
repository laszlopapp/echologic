class RemoveCategoryIdFromStatementNode < ActiveRecord::Migration
  def self.up
    remove_column :statement_nodes, :category_id
  end

  def self.down
    add_column :statement_nodes, :category_id, :integer
  end
end
