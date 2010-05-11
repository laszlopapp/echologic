class RefactorStatements < ActiveRecord::Migration
  def self.up
    #Rename Table
    rename_table :statements, :statement_nodes
    #remove work package id
    remove_column :statement_nodes, :work_package_id
    #add statement_id
    add_column :statement_nodes, :statement_id, :integer
    #add statement table
    create_table :statements do |t|
      t.integer :original_language_id
    end
    #get all statement Node objects and create a statement for each
    statement_nodes = StatementNode.all.each do |node|
      statement = Statement.create
      node.statement_id = statement.id
      node.save
    end
  end
  def self.down
    drop_table :statements
    remove_column :statement_nodes, :statement_id
    add_column :statement_nodes, :workpackage_id, :integer
    rename_table :statements_nodes, :statements
  end
end
