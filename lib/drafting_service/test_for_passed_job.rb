class TestForPassedJob < Struct.new(:incorporable_id)

  def perform
    incorporable = StatementNode.find(incorporable_id)
    if !incorporable.nil? and !incorporable.incorporated?
      DraftingService.instance.pass(incorporable)
    end
  end
end
