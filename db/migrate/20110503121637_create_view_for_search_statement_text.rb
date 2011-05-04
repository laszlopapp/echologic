class CreateViewForSearchStatementText < ActiveRecord::Migration
  def self.up
    create_view :search_statement_text,
    "SELECT DISTINCT s.id AS statement_id, d.title AS title, 
                     d.text AS text, d.language_id AS language_id, tags.value AS tag 
     FROM statements s 
     LEFT JOIN statement_documents d ON d.statement_id = s.id 
     LEFT JOIN tao_tags ON (tao_tags.tao_id = s.id and tao_tags.tao_type = 'Statement') 
     LEFT JOIN tags ON tao_tags.tag_id = tags.id 
     WHERE d.current = 1 " do |t|
      t.column :statement_id
      t.column :title
      t.column :text
      t.column :language_id
      t.column :tag
    end
  end

  def self.down
    drop_view :search_statement_text
  end
end
