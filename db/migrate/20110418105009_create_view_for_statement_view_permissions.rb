class CreateViewForStatementViewPermissions < ActiveRecord::Migration
  def self.up
    create_view :closed_statement_permissions,
    "select statements.id AS statement_id, tao_users.tao_id AS user_id from statements
     LEFT JOIN tao_tags AS tao_statements  ON statements.id = tao_statements.tao_id AND tao_statements.tao_type = 'Statement' AND tao_statements.context_id = 586794338
     LEFT JOIN tags      ON tags.id = tao_statements.tag_id
     LEFT JOIN tao_tags AS tao_users ON tags.id = tao_users.tag_id AND tao_users.tao_type = 'User' AND tao_users.context_id = 549825790
     WHERE SUBSTR(tags.value, 1, 2) = '**';" do |t|
      t.column :statement_id
      t.column :user_id
    end
    
    create_view :search_statement_nodes, 
    "SELECT DISTINCT s.*, statements.editorial_state_id,
     echos.supporter_count, closed_statement_permissions.statement_id AS closed_statement,
     closed_statement_permissions.user_id AS allowed_user_id from statement_nodes s
     LEFT JOIN statements ON statements.id = s.statement_id
     LEFT OUTER JOIN echos ON echos.id = s.echo_id
     LEFT OUTER JOIN closed_statement_permissions ON closed_statement_permissions.statement_id = statements.id
     WHERE s.question_id is NULL" do |t|
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
      t.column :allowed_user_id
    end
  end

  def self.down
    drop_view :search_statement_nodes
    drop_view :closed_statement_permissions
  end
end
