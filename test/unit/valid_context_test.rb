require 'test_helper'

class ValidContextTest < ActiveSupport::TestCase
  # Valid Context may not be saved empty.
  def test_no_empty_saving
    @vc = ValidContext.new
    assert !@vc.save
  end

  # Topic contexts must connect to context topic and have a statement node has type, affection connect to context affection must have an User as type
  def test_tao_type
    @vc = valid_contexts(:valid_context_topic)
    assert EnumKey.find_by_code("topic").id, @vc.context_id
    assert StatementNode.name, @vc.tao_type
    
    @vc = valid_contexts(:valid_context_affection)
    assert EnumKey.find_by_code("affection").id, @vc.context_id
    assert User.name, @vc.tao_type
  end
end
