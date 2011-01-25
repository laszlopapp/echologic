class RenameImprovementProposalAsImprovement < ActiveRecord::Migration
  def self.up
    execute "UPDATE statement_nodes SET type = 'Improvement' WHERE type = 'ImprovementProposal'"
  end

  def self.down
    execute "UPDATE statement_nodes SET type = 'ImprovementProposal' WHERE type = 'Improvement'"
  end
end
