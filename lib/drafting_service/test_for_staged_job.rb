class TestForStagedJob < Struct.new(:statement_node_id, :timestamp)
  
  def perform
    statement = ImprovementProposal.find(statement_node_id)
    statement.reload
    
    if !statement.nil? and statement.ready? and statement.state_since == timestamp
      DraftingService.instance.stage(statement)
    end
  end
end
