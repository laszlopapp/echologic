class AddLockedByAndLockedAtToStatementDocument < ActiveRecord::Migration
  def self.up
    add_column :statement_documents, :locked_by, :integer
    add_column :statement_documents, :locked_at, :datetime
  end

  def self.down
    remove_columns :statement_documents, :locked_by, :locked_at
  end
end
