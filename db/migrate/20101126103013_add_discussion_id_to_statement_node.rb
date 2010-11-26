class AddDiscussionIdToStatementNode < ActiveRecord::Migration
  def self.up
    add_column :statement_nodes, :discussion_id, :integer
  end

  def self.down
    remove_column :statement_nodes, :discussion_id
  end
end
