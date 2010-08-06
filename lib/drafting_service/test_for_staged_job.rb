class TestForStagedJob < Struct.new(:statement_node_id, :timestamp)
  
  def perform
    statement = StatementNode.find(statement_node_id)
    DraftingService.instance.stage(statement) if !statement.nil? and statement.ready? and statement.state_since == timestamp
  end
end
