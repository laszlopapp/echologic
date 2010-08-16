class ApprovalReminderMailJob < Struct.new(:incorporable_id, :timestamp)

  def perform
    incorporable = StatementNode.find(incorporable_id)
    if !incorporable.nil? and incorporable.approved? and incorporable.state_since == timestamp
      if incorporable.times_passed == 0
        DraftingService.instance.send_approval_reminder(incorporable)
      elsif incorporable.times_passed == 1
        DraftingService.instance.send_supporters_approval_reminder(incorporable)
      end
    end
  end
end
