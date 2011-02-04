

namespace :db do
  desc "Set root_id and parent_id and initialize left/right for all old statement nodes"
  task :fix_nested_set_structure => :environment do
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
    ProArgument.all.each do |a|
      a.root_id = a.parent.root_id
      a.save
    end
    ContraArgument.all.each do |a|
      a.root_id = a.parent.root_id
      a.save
    end
    FollowUpQuestion.all.each do |fq|
      fq.root_id = fq.parent.root_id
      fq.save
    end
    StatementNode.rebuild!
  end
end

