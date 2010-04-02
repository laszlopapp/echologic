class RefactorStatements < ActiveRecord::Migration
  def self.up
    rename_table :statements, :statement_nodes
    remove_column :statement_nodes, :work_package_id
    add_column :statement_nodes, :statement_id, :integer
    create_table :statements do |t|
      t.integer :original_language_id
    end
  end
  def self.down
    drop_table :statements
    remove_column :statement_nodes, :statement_id
    add_column :statement_nodes, :workpackage_id
    rename_table :statements, :statement_id
  end
end
