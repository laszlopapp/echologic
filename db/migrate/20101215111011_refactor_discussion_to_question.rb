class RefactorDiscussionToQuestion < ActiveRecord::Migration
  def self.up
    execute "UPDATE statement_nodes SET type = 'Question' WHERE type = 'Discussion'"
    rename_column :statement_nodes, :discussion_id, :question_id
  end

  def self.down
    execute "UPDATE statement_nodes SET type = 'Discussion' WHERE type = 'Question'"
    rename_column :statement_nodes, :question_id, :discussion_id
  end
end
