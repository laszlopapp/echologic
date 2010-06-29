class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    # statement nodes
    add_index :statement_nodes, [:type,:statement_id,:state_id,:echo_id,:created_at], :name => "search_by_statement_node_info_index"
    add_index :statement_nodes, [:creator_id]
    # statement documents
    execute "CREATE INDEX `search_by_statement_document_info_index` ON `statement_documents` (`title`, `text`(400), `language_id`, `statement_id`)"
    # enum keys
    add_index :enum_keys, [:code, :enum_name]
    #enum_values
    add_index :enum_values, [:language_id]
    #spoken_languages
    add_index :spoken_languages, [:user_id, :level_id]
    # users
    add_index :users, [:email]
    # profiles
    execute "CREATE INDEX `search_by_profile_info_index` ON `profiles` (`first_name`, `last_name`, `city`, `country`,`about_me`(2), `motivation`(2))"
    # memberships
    add_index :memberships, [:position, :organisation]
  end

  def self.down
    remove_index :statement_nodes, :name => "search_by_statement_node_info_index"
    remove_index :statement_nodes, :column => :creator_id
    
    remove_index :statement_documents, :name => "search_by_statement_document_info_index"
    
    remove_index :enum_keys, :column => [:code, :enum_name]
    
    remove_index :enum_values, :column => [:language_id]
    
    remove_index :spoken_languages, [:user_id, :level_id]
    
    remove_index :users, :column => [:email]
    
    remove_index :profiles, :name => "search_by_profile_info_index"
    
    remove_index :memberships, :column => [:position, :organisation]
  end
end
