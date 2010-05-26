require 'test_helper'

class TaoTagsControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @controller = TaoTagsController.new
  end

  test "should create tao tag" do
    assert_difference('TaoTag.count') do
      post :create, :tao_tag => { :tao_id => User.first.id, :context_id => EnumKey.find_by_code("affection").id, :tao_type => "User" }, :tag => { :value => 'baby_on_board', :language_id => EnumKey.find_by_code("en").id}
    end
  end

  test "should create many tao tags" do
    assert_difference("TaoTag.count", 2) do
      post :create, :tao_tag => { :tao_id => User.first.id, :context_id => EnumKey.find_by_code("engagement").id, :tao_type => "User" }, :tag => {:value => 'Limpopo, Irokumata', :language_id => EnumKey.find_by_code("en").id }
    end
  end


  test "should destroy tao tag" do
    assert_difference('TaoTag.count', -1) do
      delete :destroy, :id => tao_tags(:joe_water_ngo).to_param
    end
  end
end
