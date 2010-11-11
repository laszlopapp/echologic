class TurnQuestionsIntoDiscussions < ActiveRecord::Migration
  def self.up
    execute "UPDATE statement_nodes SET type = 'Discussion' WHERE type = 'Question'"
  end

  def self.down
    execute "UPDATE statement_nodes SET type = 'Question' WHERE type = 'Discussion'"
  end
end
