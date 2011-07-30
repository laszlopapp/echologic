class CreateViewForStatementPermissions < ActiveRecord::Migration
  def self.up

    create_view :statement_permissions,
    "SELECT statements.id AS statement_id, tao_users.tao_id AS user_id
     FROM statements
          LEFT JOIN tao_tags AS tao_statements ON statements.id = tao_statements.tao_id AND
                                                  tao_statements.tao_type = 'Statement' AND
                                                  tao_statements.context_id = (SELECT id FROM enum_keys WHERE type = 'TagContext' AND code = 'topic')
          LEFT JOIN tags ON tags.id = tao_statements.tag_id
          LEFT JOIN tao_tags AS tao_users ON tags.id = tao_users.tag_id AND
                                             tao_users.tao_type = 'User' AND
                                             tao_users.context_id = (SELECT id FROM enum_keys WHERE type = 'TagContext' AND code = 'decision_making')
     WHERE SUBSTR(tags.value, 1, 2) = '**'" do |t|
      t.column :statement_id
      t.column :user_id
    end

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
      t.column :editorial_state_id
      t.column :supporter_count
      t.column :closed_statement
      t.column :granted_user_id
    end
  end

  def self.down
    drop_view :statement_permissions
    drop_view :search_statement_nodes
  end
end
