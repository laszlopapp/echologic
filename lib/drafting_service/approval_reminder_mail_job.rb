class ApprovalReminderMailJob < Struct.new(:incorporable_id, :timestamp)

  def perform
    incorporable = StatementNode.find(incorporable_id)
    if !incorporable.nil? and incorporable.approved? and incorporable.state_since == timestamp
      DraftingService.instance.remind(incorporable)
    end
  end
end
