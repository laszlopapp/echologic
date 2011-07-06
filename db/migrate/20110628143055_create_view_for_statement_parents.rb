class CreateViewForStatementParents < ActiveRecord::Migration
  def self.up
    create_view :statement_nodes_parents,
     "SELECT id,
             type,
             parent_id,
             (SELECT IF (p.type='CasHub', parent_id, id)
                FROM statement_nodes p WHERE p.id = s.parent_id)
             AS parent_node_id
      FROM statement_nodes s;" do |t|
      t.column :id
      t.column :type
      t.column :parent_id
      t.column :parent_node_id
    end
  end

  def self.down
    drop_view :statement_nodes_parents
  end
end
