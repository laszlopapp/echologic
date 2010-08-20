class AddDraftingStateToStatementNode < ActiveRecord::Migration
  def self.up
    add_column :statement_nodes, :drafting_state, :string, :limit => 20
    ImprovementProposal.all.each do |ip|
      ip.update_attribute(:drafting_state, "tracked")
    end
  end

  def self.down
    remove_column :statement_nodes, :drafting_state
  end
end
