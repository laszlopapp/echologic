class AddTopLevelToStatementNode < ActiveRecord::Migration
  def self.up
    add_column :statement_nodes, :top_level, :boolean, :default => true
    drop_view :search_statement_nodes
    create_view :search_statement_nodes,
    "SELECT DISTINCT n.*, s.editorial_state_id,
            e.supporter_count, sp.statement_id AS closed_statement,
            sp.user_id AS granted_user_id
     FROM statement_nodes n
          LEFT JOIN statements s ON s.id = n.statement_id
          LEFT JOIN echos e ON n.echo_id = e.id
          LEFT OUTER JOIN statement_permissions sp ON s.id = sp.statement_id
     WHERE n.question_id IS NULL" do |t|
      t.column :id
      t.column :type
      t.column :parent_id
      t.column :root_id
      t.column :creator_id
      t.column :echo_id
      t.column :created_at
      t.column :updated_at
      t.column :statement_id
      t.column :drafting_state
      t.column :lft
      t.column :rgt
      t.column :question_id
      t.column :twin_hub_id
      t.column :top_level
      t.column :editorial_state_id
      t.column :supporter_count
      t.column :closed_statement
      t.column :granted_user_id
    end
  end

  def self.down
    remove_column :statement_nodes, :top_level
    drop_view :search_statement_nodes
  end
end
