namespace :drafting do
  desc "Initializes the drafting state machine for all Improvement Proposals"
  task :initialize => :environment do
    DraftingService.time_ready = 1.hours   #   In order to make the approval process start faster
    Proposal.all.each do |proposal|
      proposal.children_statements.each do |ip|
        if DraftingService.instance.test_readiness(ip)
          DraftingService.instance.readify(ip)
          sleep(5)  #  So that we don't create a flood of Jobs at the very same time
        end
      end
    end
  end
end