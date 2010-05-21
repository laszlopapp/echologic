class AddStateIdToStatementNode < ActiveRecord::Migration
  def self.up
    rename_column :statement_nodes, :state, :state_id
    StatementNode.all.each do |node|
      node.state_id = EnumKey.find_by_key_and_enum_name(node.state_id+1,"statement_states").id
      node.save(false)
    end
  end

  def self.down
    rename_column :statement_nodes, :state_id, :state
  end
end
