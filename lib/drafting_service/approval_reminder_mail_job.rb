class ApprovalReminderMailJob < Struct.new(:statement_node_id)
  
  def perform
    statement = StatementNode.find(statement_node_id)
    DraftingService.instance.send_approval_reminder(statement) if !statement.nil? and statement.approved?
  end
end
