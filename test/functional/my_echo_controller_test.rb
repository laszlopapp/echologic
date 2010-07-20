require 'test_helper'

class MyEchoControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @controller = MyEchoController.new
  end

  test "should get welcome" do
    get :welcome
    assert_response :success
  end

  test "should get profile" do
    get :profile
    assert_response :success
  end

  test "should get roadmap" do
    get :roadmap
    assert_response :success
  end



end
