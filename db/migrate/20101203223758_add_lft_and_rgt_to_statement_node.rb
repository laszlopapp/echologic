class AddLftAndRgtToStatementNode < ActiveRecord::Migration
  def self.up
    Question.all.each do |q|
      q.root_id = q.id
      q.save
    end
    Proposal.all.each do |p|
      p.root_id = p.parent_id
      p.save
    end
    Improvement.all.each do |ip|
      ip.root_id = ip.parent.root_id
      ip.save
    end
    add_column :statement_nodes, :lft, :integer
    add_column :statement_nodes, :rgt, :integer

    StatementNode.rebuild!
  end

  def self.down
    remove_column :statement_nodes, :lft
    remove_column :statement_nodes, :rgt
  end
end
