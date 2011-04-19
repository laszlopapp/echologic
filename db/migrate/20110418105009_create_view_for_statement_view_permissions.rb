class CreateViewForStatementViewPermissions < ActiveRecord::Migration
  def self.up
    create_view :statement_permissions, 
    "select statements.id AS statement_id, tags.id AS tag_id from statements
      LEFT JOIN tao_tags  ON statements.id = tao_tags.tao_id AND tao_tags.tao_type = 'Statement'
      LEFT JOIN tags      ON tags.id = tao_tags.tag_id
      LEFT JOIN enum_keys ON enum_keys.id = tao_tags.context_id AND enum_keys.code = 'topic'
      WHERE SUBSTR(tags.value, 1, 2) = '**'" do |t|
      t.column :statement_id
      t.column :tag_id
    end
    
    create_view :user_permissions, 
    "select users.id AS user_id, tags.id AS tag_id from users
     LEFT JOIN tao_tags  ON users.id = tao_tags.tao_id AND tao_tags.tao_type = 'User'
     LEFT JOIN tags      ON tags.id = tao_tags.tag_id
     LEFT JOIN enum_keys ON enum_keys.id = tao_tags.context_id AND enum_keys.code = 'decision_making'
     WHERE SUBSTR(tags.value, 1, 2) = '**'" do |t|
      t.column :user_id
      t.column :tag_id
    end
    create_view :closed_statement_permissions, 
    "select statement_permissions.statement_id AS statement_id, user_permissions.user_id AS user_id FROM statement_permissions
     LEFT JOIN user_permissions
     ON statement_permissions.tag_id = user_permissions.tag_id" do |t|
      t.column :statement_id
      t.column :user_id
    end
    
    create_view :search_statement_nodes, 
    "SELECT DISTINCT s.*, statements.editorial_state_id, d.language_id, d.title, d.text,
     echos.supporter_count, closed_statement_permissions.statement_id AS closed_statement,
     closed_statement_permissions.user_id AS allowed_user_id from statement_nodes s
     LEFT JOIN statements ON statements.id = s.statement_id
     LEFT JOIN statement_documents d ON s.statement_id = d.statement_id
     LEFT OUTER JOIN echos ON echos.id = s.echo_id
     LEFT OUTER JOIN closed_statement_permissions ON closed_statement_permissions.statement_id = statements.id
     WHERE d.current = 1 AND
     s.question_id is NULL AND
     s.type = 'Question'" do |t|
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
      t.column :language_id
      t.column :title
      t.column :text
      t.column :supporter_count
      t.column :closed_statement
      t.column :allowed_user_id
    end
  end

  def self.down
    drop_view :search_statement_nodes
    drop_view :closed_statement_permissions
    drop_view :user_permissions
    drop_view :statement_permissions
  end
end
