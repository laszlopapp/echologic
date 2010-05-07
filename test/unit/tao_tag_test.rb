require 'test_helper'

class TaoTagTest < ActiveSupport::TestCase
  # TaoTag may not be saved empty.
  def test_no_empty_saving
    tao = TaoTag.new
    assert !tao.save, 'Do not save empty tao_tag'
  end
  
  # User has to have a single tag for a certain context.
  def test_value_uniqueness
    tao = tao_tags(:user_earth_ngo)
    tag = tags(:water)    
    tao_2 = TaoTag.new(:tag => tag, :context_id => tao.context_id, :tao_id => tao.tao_id)
    tao_3 = TaoTag.new(:tag => tao.tag, :context_id => tao.context_id, :tao_id => tao.tao_id, :tao_type => tao.tao_type)
    
    assert tao_2.save, 'different tag for same tao in the same context should be saved'    
    assert !tao_3.save, 'same tag for same tao on same context should be unique'
  end

  
end