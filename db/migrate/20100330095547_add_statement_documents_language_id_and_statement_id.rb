class AddStatementDocumentsLanguageIdAndStatementId < ActiveRecord::Migration
  def self.up
    #add language id and statement id to documents
    #question: why the hell do we need the other stuff?
    change_table :statement_documents do |t|
      t.integer :language_id
      t.integer :translated_document_id, :statement_id, :current
      t.timestamps
    end
    #get all nodes, get all their documents, add the statement id to them, and initiate them with the german language (?)
    StatementNode.all.each do |node|
      if !node.statement_id.nil? and !node.document_id.nil?
        statement = Statement.find(node.statement_id)
        document = StatementDocument.find(node.document_id)
        document.statement_id = node.statement_id
        document.language_id = EnumKey.find_by_code_and_enum_name("de","languages").id
        statement.original_language_id = EnumKey.find_by_code_and_enum_name("de","languages").id
        statement.save
        document.save
         #now time to restructure all the statement tagging
        tag = Tag.find(node.category_id)
        taotag = TaoTag.new(:tag_id => tag.id, :tao_id => node.id, :tao_type => 'StatementNode', :context_id => EnumKey.find_by_code_and_enum_name("topic","tag_contexts") )
        
        taotag.save
      end
      
     
      
    end
  end

  def self.down
    remove_column :statement_documents, :language_id
    remove_column :statement_documents, :translated_document_id
    remove_column :statement_documents, :statement_id
    remove_column :statement_documents, :current
    remove_column :statement_documents, :created_at
    remove_column :statement_documents, :updated_at
  end
end
