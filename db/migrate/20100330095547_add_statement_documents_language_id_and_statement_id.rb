class AddStatementDocumentsLanguageIdAndStatementId < ActiveRecord::Migration
  def self.up
    change_table :statement_documents do |t|
      t.integer :language_id
      t.integer :translated_document_id, :statement_id, :current
      t.timestamps
    end
  end

  def self.down
    change_table :statement_documents do |t|
      t.remove_column :language_id
      t.remove_column :translated_document_id
      t.remove_column :statement_id
      t.remove_column :current
      t.remove_column :created_at
      t.remove_column :updated_ad
    end
  end
end
