require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  def setup
    login_as :admin
    @controller = Users::ReportsController.new
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "should show report" do
    get :show, :id => reports(:joe_active_report).to_param
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => reports(:joe_active_report).to_param
    assert_response :success
  end

  test "should create report" do
    assert_difference('Report.count') do
      post :create, :report => {:reason => "there is no reason", :suspect_id => reports(:joe_active_report).to_param }
    end
    assert_redirected_to ('connect/search')
  end

  test "should update report" do
    put :update, :id => reports(:joe_active_report).to_param, :report => {:reason => "after all there was a reason"}
    assert_redirected_to reports_path
  end

  test "should destroy report" do
    assert_difference('Report.count', -1) do
      delete :destroy, :id => reports(:joe_active_report).to_param
    end

    assert_redirected_to reports_path
  end
end
