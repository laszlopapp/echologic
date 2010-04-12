require File.join(File.dirname(__FILE__), "spec_helper" )

describe Echo do 
  context "visit a statement" do 
    before(:each) do
      @user = User.first
      @echoable = Statement.first
      @old_count = @echoable.echo.visitor_count rescue 0
      @user_echo = @user.visited!(@echoable)
    end
    
    it "should be marked as visited" do 
      @user_echo.visited.should be_true
    end
    
    it "should update echo's visitor count" do
      @user_echo.echo.visitor_count.should >= @old_count
    end
    
    it "should include user in echoable's visitor list" do 
      @echoable.visitors.should include @user
    end
  end
  
  context "support a statement" do 
    before(:each) do 
      @user = User.first
      @echoable = Statement.first
      @old_count = @echoable.echo.supporter_count rescue 0
      @user_echo = @user.supported!(@echoable)
    end
    
    it "should be marked as supported" do 
      @user_echo.supported.should be_true
    end
    
    it "should update echo's supporter count" do 
      @user_echo.echo.supporter_count.should >= @old_count
    end
    
    it "should include user in echoable's supporter list" do 
      @echoable.supporter.should include @user
    end
  end
end
