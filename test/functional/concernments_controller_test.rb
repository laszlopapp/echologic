require 'test_helper'

class ConcernmentsControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @controller = Users::ConcernmentsController.new
  end

  test "should create concernment" do
    assert_difference('Concernment.count') do
      post :create, :concernment => { :sort => 0 }, :tag => { :value => 'baby_on_board' }
    end
  end

  test "should create many concernments" do
    assert_difference("Concernment.count", 2) do
      post :create, :concernment => { :sort => 0 }, :tag => {:value => 'Limpopo, Irokumata' }
    end
  end


  test "should destroy concernment" do
    assert_difference('Concernment.count', -1) do
      delete :destroy, :id => concernments(:joe_energy).to_param
    end
  end
end
