class InitializeDraftingStateInImprovementProposal < ActiveRecord::Migration
  def self.up
    ImprovementProposal.all.each do |ip|
      ip.drafting_state = 'tracked'
      ip.save
    end
  end

  def self.down
  end
end
