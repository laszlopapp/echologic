require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @controller = Users::MembershipsController.new
  end
 

  test "should get new" do
    get :new
    assert_response (:error, "template new missing")
  end

  test "should create membership" do
    assert_difference('Membership.count') do
      post :create, :membership => {:organisation => "Greenpeace", :position => "Big Chief of the High Seas"}
    end
  end

  test "should show membership" do
    get :show, :id => memberships(:joe_greenpeace).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => memberships(:joe_greenpeace).to_param
    assert_response :success
  end

  test "should update membership" do
    put :update, :id => memberships(:joe_greenpeace).to_param, :membership => {:organisation => "AlQaeda", :position => "Suicidal Puppet" }
  end

  test "should destroy membership" do
    assert_difference('Membership.count', -1) do
      delete :destroy, :id => memberships(:joe_greenpeace).to_param
    end
  end
end
