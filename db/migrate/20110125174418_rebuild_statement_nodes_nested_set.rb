class RebuildStatementNodesNestedSet < ActiveRecord::Migration
  def self.up
    StatementNode.rebuild!
  end

  def self.down
  end
end
