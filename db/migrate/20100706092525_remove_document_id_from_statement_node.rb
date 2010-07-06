class RemoveDocumentIdFromStatementNode < ActiveRecord::Migration
  def self.up
    remove_column :statement_nodes, :document_id
  end

  def self.down
    add_column :statement_nodes, :document_id, :integer
  end
end
