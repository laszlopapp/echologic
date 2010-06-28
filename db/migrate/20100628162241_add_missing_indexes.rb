class AddMissingIndexes < ActiveRecord::Migration
  def self.up
#    # statement nodes
#    add_index :statement_nodes, [:id, :type]
#    add_index :statement_nodes, [:id, :type,:state_id]
#    add_index :statement_nodes, [:type]
#    add_index :statement_nodes, [:type,:state_id]
#    # statement documents
#    add_index :statement_documents, [:language_id]
#    add_index :statement_documents, [:statement_id, :language_id]
    add_index(:statement_documents, [:title, :text, :statement_id], :length => {:text => 1000})
    add_index :statement_documents, [:author, :language_id]
    # enum keys
    add_index :enum_keys, [:code]
    add_index :enum_keys, [:code, :enum_name]
    #enum_values
    add_index :enum_values, [:language_id]
    add_index :enum_values, [:value]
    # users
    add_index :users, [:email]
    # profiles
    add_index :profiles, [:first_name, :last_name, :city, :country, :about_me, :motivation]
    # memberships
    add_index :memberships, [:position, :organisation]
  end

  def self.down
  end
end
