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

    StatementDocument.all.each do |statement_document|
      sh = StatementHistory.new
      sh.statement_document_id = statement_document.id
      sh.statement_id = statement_document.statement_id
      sh.author_id = statement_document.author_id
      action = statement_document.translated_document_id.nil? ? StatementHistory.statement_actions("created") : StatementHistory.statement_actions("translated") 
      sh.action_id = action.id
      sh.old_document_id = statement_document.translated_document_id
      sh.created_at = statement_document.created_at
      sh.save
    end
    remove_column :statement_documents, :author_id, :translated_document_id
    StatementDocument.all.each do |sd|
      sd.update_attribute(:current, true)
    end
  end

  def self.down
    drop_table :statement_histories
    add_column :statement_documents, :author_id, :integer
    add_column :statement_documents, :translated_document_id, :integer
  end
end
