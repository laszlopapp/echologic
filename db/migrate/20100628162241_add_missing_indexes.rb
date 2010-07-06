class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    # statement nodes
    add_index :statement_nodes, [:echo_id, :id]
    add_index :statement_nodes, [:id,:statement_id]
    add_index :statement_nodes, [:type]
    add_index :statement_nodes, [:state_id]
    add_index :statement_nodes, [:creator_id]
    # statement documents
    add_index :statement_documents, [:statement_id, :id]
    add_index :statement_documents, [:language_id]
    # enum keys
    add_index :enum_keys, [:enum_name, :id]
    add_index :enum_keys, [:code, :id]
    add_index :enum_keys, [:code, :enum_name, :id]
    #enum_values
    add_index :enum_values, [:language_id]
    #spoken_languages
    add_index :spoken_languages, [:user_id, :level_id]
    # users
    add_index :users, [:email]
    # profiles
    add_index :profiles, [:user_id, :id]
    # memberships
    add_index :memberships, [:user_id, :id]
  end

  def self.down
    
  end
end
