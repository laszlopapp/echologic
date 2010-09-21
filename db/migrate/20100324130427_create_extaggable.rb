class CreateExtaggable < ActiveRecord::Migration
  def self.up
    
#    rename_table :tags, :tag_words
    add_column :tags, :language_id, :integer
    create_table :valid_contexts do |t|
      t.integer :context_id
      t.string :tao_type
    end
    
    create_table :tao_tags do |t|
      t.column :tag_id, :integer
      t.column :tao_id, :integer
      # we don't use taggers for now, but it cold be reactivated
      # t.column :tagger_id, :integer
      # t.column :tagger_type, :string
      
      # You should make sure that the column created is
      # long enough to store the required class names.
      t.column :tao_type, :string
      t.column :context_id, :string
      
      t.column :created_at, :datetime
    end
    
    add_index :tao_tags, :tag_id
    add_index :tao_tags, [:tao_id, :tao_type, :context_id]
    
    
    
    #now that we have enum keys and values and valid contexts, time to load the seed data
    Rake::Task['db:seed'].invoke
    
  end
  
  def self.down
    drop_table :valid_contexts
    remove_column :tags, :language_id
    drop_table :tao_tags
  end
end
