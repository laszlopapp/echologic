class CreateStatementHistories < ActiveRecord::Migration
  def self.up
    # Load Statement Actions Enum Keys
    Rake::Task['db:seed'].invoke
    
    create_table :statement_histories do |t|
      t.integer :statement_document_id
      t.integer :statement_id
      t.integer :author_id
      t.integer :action_id
      t.integer :old_document_id
      t.integer :incorporated_node_id
      t.string :comment
      t.datetime :created_at
    end
    
#    StatementDocument.all.each do |statement_document|
#      sh = StatementHistory.new
#      sh.statement_document_id = statement_document.id
#      sh.statement_id = statement_document.statement_id
#      sh.author_id = statement_document.author_id
#      sh.action = EnumKey.find_by_code_and_enum_name("new","statement_actions")
#      sh.old_document_id = statement_document.translated_document_id
#      sh.created_at = statement_document.created_at
#      sh.save
#    end
    remove_column :statement_documents, :author_id, :current, :translated_document_id
    
  end

  def self.down
#    drop_table :statement_histories
    add_column :statement_documents, :author_id, :integer
    add_column :statement_documents, :current, :integer
    add_column :statement_documents, :translated_document_id, :integer
  end
end
