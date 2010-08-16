class TestForPassedJob < Struct.new(:incorporable_id)

  def perform
    begin
      StatementNode.transaction do
        incorporable = StatementNode.find(incorporable_id)
        if !incorporable.nil? and !incorporable.incorporated?
          incorporable.times_passed += 1
          incorporable.drafting_info.save
          incorporable.reload
          if incorporable.times_passed == 1
            DraftingService.instance.send_passed_email(incorporable)
            DraftingService.instance.stage(incorporable)
          elsif incorporable.times_passed == 2
            DraftingService.instance.send_supporters_passed_email(incorporable)
            DraftingService.instance.reset_incorporable(incorporable)
            DraftingService.instance.select_approved(incorporable)
          end
        end
      end
    rescue StandardError => error
      Rails.logger.error "Error occured in test for passed job: \n" + error.backtrace
    else
      Rails.logger.info "Test for passed job has completed successfully."
    end
  end
end
