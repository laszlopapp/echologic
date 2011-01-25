class AddQuestionIdToStatementNode < ActiveRecord::Migration
  def self.up
    add_column :statement_nodes, :question_id, :integer
  end

  def self.down
    remove_column :statement_nodes, :question_id
  end
end
