class AddMissingIndexes < ActiveRecord::Migration
  def self.up

    # users
    add_index :users, [:email, :id], :name => "idx_users_email_pk", :unique => true

    # profiles
    add_index :profiles, [:user_id, :id], :name => "idx_profiles_user_pk"

    # spoken_languages
    add_index :spoken_languages, [:user_id, :level_id, :id], :name => "idx_spoken_languages_users_level_pk"

    # memberships
    add_index :memberships, [:user_id, :id], :name => "idx_memberships_user_pk"

    # statement nodes
    add_index :statement_nodes, [:echo_id, :id], :name => "idx_statement_nodes_echo_pk"
    add_index :statement_nodes, [:statement_id, :id], :name => "idx_statement_nodes_statement_pk"
    add_index :statement_nodes, [:type], :name => "idx_statement_nodes_type"
    add_index :statement_nodes, [:state_id], :name => "idx_statement_nodes_state"
    add_index :statement_nodes, [:creator_id], :name => "idx_statement_nodes_creator"

    # statement documents
    add_index :statement_documents, [:statement_id, :id], :name => "idx_statement_documents_statement_pk"
    add_index :statement_documents, [:language_id, :id], :name => "idx_statement_documents_language_pk"

    # enum keys
    add_index :enum_keys, [:enum_name, :id], :name => "idx_enum_keys_name_pk"
    add_index :enum_keys, [:enum_name, :code, :id], :name => "idx_enum_keys_name_code_pk"

    # enum_values
    add_index :enum_values, [:language_id, :id], :name => "idx_enum_values_code_pk"
  end

  def self.down

  end
end
