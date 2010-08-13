namespace :drafting do
  desc "move all Web Address sorts to type_ids"
  task :initialize => :environment do
    Proposal.all.each do |proposal|
      proposal.sorted_children.each do |child|
        DraftingService.instance.readify(child) if DraftingService.instance.test_readiness(child)
      end
    end
  end
end