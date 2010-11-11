require File.join(File.dirname(__FILE__), "/spec_helper" )

describe Statement do
  
  context "creating a discussion" do
    before(:each) do 
      @user = User.find_by_email("editor@echologic.org")
      @document = StatementDocument.new(:title => 'Is it a discussion?', :text => 'The discussion is, is this a discussion?') 
      @statement_node = Discussion.new(:creator => @user, :document =>  @document)
    end
    
    it "should be valid" do
      @statement_node.should be_valid
    end
    
    it "should be of Type 'discussion'" do
      @statement_node.class.name.should == "Discussion"  
    end
    
    it "should have an creator" do
      @statement_node.creator.should_not be_nil
    end
    
    it "should not save without a creator" do
      @statement_node.creator = nil
      @statement_node.should_not be_valid
    end
    
    it "should not save without a document" do
      @statement_node.document = nil
      @statement_node.should_not be_valid
    end
    
    it "should not save without a valid parent (Discussion or none)" do
      @statement_node.parent = Discussion.first
      @statement_node.should be_valid
      @statement_node.parent = Proposal.first
      @statement_node.should_not be_valid
      @statement_node.parent = ImprovementProposal.first
      @statement_node.should_not be_valid
    end
    
    it "should not save without a root when it has a parent" do
      @statement_node.root_id = nil
      @statement_node.parent = nil
      @statement_node.should be_valid
      @statement_node.parent = Discussion.first
      @statement_node.should_not be_valid
      @statement_node.root_id_ = Discussion.first.id
      @statement_node.should be_valid
    end
    
  end
  
  context "creating a proposal for a discussion" do
    before(:each) do
      @user = User.find_by_email("editor@echologic.org")
      @document = StatementDocument.new(:title => 'A proposal', :text => 'For every discussion, theres a proposal!') 
      @statement_node = Proposal.new(:parent => Discussion.first, :creator => @user, :document => @document)
    end
    
    it "should be valid" do
      @statement_node.should be_valid
    end
    
    it "should be of type 'Proposal'" do
      @statement_node.class.name.should == 'Proposal'
    end
    
    it "should not save without a valid parent (a discussion)" do
      @statement_node.parent = nil
      @statement_node.should_not be_valid
      @statement_node.parent = Proposal.first
      @statement_node.should_not be_valid
    end
  end
  
  context "creating an improvementproposal for a proposal" do
    before(:each) do
      @user = User.find_by_email("editor@echologic.org")
      @document = StatementDocument.new(:title => 'Improvement', :text => 'I am a proposal to improve this proposal!!')
      @statement_node = ImprovementProposal.new(:parent => Proposal.first, :creator => @user, :document => @document)
    end
   
    it "should be valid" do
      @statement_node.should be_valid
    end
    
    it "should be of type 'ImprovementProposal" do
      @statement_node.class.name.should == 'ImprovementProposal'
    end
    
    it "should not save without a valid parent (a proposal)" do
      @statement_node.parent = nil
      @statement_node.should_not be_valid
      @statement_node.parent = ImprovementProposal.first
      @statement_node.should_not be_valid
    end
    
  end
  
  context "loading a statement_node" do
    before(:each) do
      @discussion = Discussion.first
    end
    
    it "should have an User associated as a creator" do
      @discussion.creator.class.name.should == 'User'
    end
    
    it "should have a StatementDocument associated as a document" do
      @discussion.document.class.name.should == 'StatementDocument'
    end
  end  
  
  context "loading a discussion that already has proposals" do
    before(:each) do
      # we know that the first Discussion has two proposals already
      @discussion = Discussion.first
    end
    
    it "should have proposals accessible through .children.proposals" do
      @discussion.children.proposals.any?.should be_true
    end
  end
  
end
