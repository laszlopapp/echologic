

namespace :db do
  desc "Set root_id and parent_id and initialize left/right for all old statement nodes"
  task :fix_nested_set_structure => :environment do
    WebAddress.all.select{|a| !a.type.code.eql?("email") &&
                              !a.address.starts_with?('http://') &&
                              !a.address.starts_with?('www.')}.each do |web_address|
      web_address.address = 'http://' + web_address.address
      puts 'Fixed: ' + web_address.address if web_address.save
    end
  end
end

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