class MoveTagsAndPublishStateFromStatementNodeToStatement < ActiveRecord::Migration
  def self.up
    execute "UPDATE tao_tags 
    LEFT JOIN statement_nodes   ON    statement_nodes.id = tao_tags.tao_id
    SET tao_tags.tao_id = statement_nodes.statement_id, tao_tags.tao_type = 'Statement' WHERE tao_tags.tao_type = 'StatementNode'"
    add_column :statements, :editorial_state_id, :integer
    execute "UPDATE statements 
    LEFT JOIN statement_nodes   ON    statement_nodes.statement_id = statements.id
    SET statements.editorial_state_id = statement_nodes.editorial_state_id WHERE statement_nodes.statement_id = statements.id"
    remove_column :statement_nodes, :editorial_state_id
  end

  def self.down
    execute "UPDATE tao_tags 
    LEFT JOIN statements   ON    statements.id = tao_tags.tao_id
    LEFT JOIN statement_nodes   ON    statements.id = statement_nodes.statement_id
    SET tao_id = statement_nodes.id, tao_tags.tao_type = 'StatementNode' WHERE tao_tags.tao_type = 'Statement'"
    add_column :statement_nodes, :editorial_state_id, :integer
    execute "UPDATE statement_nodes 
    LEFT JOIN statements   ON    statement_nodes.statement_id = statements.id
    SET statement_nodes.editorial_state_id = statements.editorial_state_id WHERE statement_nodes.statement_id = statements.id"
    remove_column :statements, :editorial_state_id
  end
end
