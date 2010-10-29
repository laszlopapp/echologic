require 'test_helper'

class MyEchoControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @controller = MyEchoController.new
    @user = users(:ben)
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
  
  test "should get setters" do 
    {'notification' => ['newsletter','activity','drafting'], 'permission' => ['authorship']}.each do |type, contents|
      contents.each do |content|
        value = @user.send("#{content}_#{type}")
        if @user.send("#{content}_#{type}?")
          put "set_#{content}_#{type}".to_sym, :id => @user.id
        else
          put "set_#{content}_#{type}".to_sym, :id => @user.id, :notify => @user.send("#{content}_#{type}?")
        end
        assert_response :success
        @user.reload
        assert_not_equal value, @user.send("#{content}_#{type}")
      end
    end
  end 
  
end
