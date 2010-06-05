require 'test_helper'

class ConnectControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as :user
    @controller = ConnectController.new
    @user = Profile.find_by_first_name('Joe')
  end
  
  test "should get show" do
    get :show
    assert_response :success
    assert_not_nil assigns(:profiles)
  end
  
  test "should get Joe" do
    get :show, :value => "Joe"
    assert_response :success
    assert_true(assigns(:profiles).include?(@user))
  end
  
  test "should get Joe in Affected" do
    get :show, :value => "Joe", :sort => EnumKey.find_by_code("affection").id
    assert_response :success
    assert_true(assigns(:profiles).include?(@user))
  end
  
  test "should not get Joe in Experts" do
    get :show, :value => "Joe", :sort => EnumKey.find_by_code("expertise").id
    assert_response :success
    assert_true(!assigns(:profiles).include?(@user))
  end
  
  test "should get roadmap" do
    get :roadmap
    assert_response :success
  end
  
end
