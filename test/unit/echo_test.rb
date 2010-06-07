require File.join(File.dirname(__FILE__), '..', 'test_helper')

class EchoTest < ActiveSupport::TestCase
  def setup
    @echoable = StatementNode.first
    # make sure we don't have a echo already
    @echoable.update_attributes!(:echo_id => nil)
    @user = User.first
    
    assert( ! @echoable.visited_by?(@user))
    assert( ! @echoable.supported_by?(@user))
  end
  
  def test_should_create_echo
    assert(echo = @echoable.find_or_create_echo, "Echo wasn't created")
    assert( ! echo.new_record?, "Echo didn't get saved")
  end
end
