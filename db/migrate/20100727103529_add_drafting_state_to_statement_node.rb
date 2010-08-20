class AddDraftingStateToStatementNode < ActiveRecord::Migration
  def self.up
    add_column :statement_nodes, :drafting_state, :string, :limit => 20, :default => 'tracked'
    ImprovementProposal.all.each do |ip|
      ip.drafting_state = 'tracked'
      ip.save
    end
  end

  def self.down
    remove_column :statement_nodes, :drafting_state
  end
end
