class TestForPassedJob < Struct.new(:statement_node_id)
  
  def perform
    statement = StatementNode.find(statement_node_id)
    if statement and !statement.incorporated?
      statement.update_attribute(:times_passed, statement.times_passed + 1)
      if statement.times_passed == 1
        DraftingService.instance.send_passed_email(statement)
        DraftingService.instance.stage(statement)
      elsif statement.times_passed == 2
        DraftingService.instance.send_supporters_passed_email(statement)
        DraftingService.instance.reset_incorporable(statement)
        DraftingService.instance.select_approved(statement)
      end
    end
  end
end
