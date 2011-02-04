class TestForStagedJob < Struct.new(:incorporable_id, :timestamp)

  def perform
    incorporable = Improvement.find(incorporable_id)
    if !incorporable.nil? and incorporable.ready? and incorporable.state_since == timestamp
      DraftingService.instance.stage(incorporable)
    end
  end
end
