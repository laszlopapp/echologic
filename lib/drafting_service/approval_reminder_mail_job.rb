class ApprovalReminderMailJob < Struct.new(:statement_node_id, :timestamp)
  
  def perform
    statement = StatementNode.find(statement_node_id)
    if !statement.nil? and statement.approved? and statement.state_since == timestamp
      if statement.times_passed == 0
        DraftingService.instance.send_approval_reminder(statement)
      elsif statement.times_passed == 1
        DraftingService.instance.send_supporters_approval_reminder(statement)
      end
    end
  end
end
