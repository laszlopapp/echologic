require 'test_helper'

class DiscussControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    #login_as :user
    @controller = DiscussController.new
    @user = Profile.find_by_first_name('User')
  end

  test "should get index without being logged on" do
    get :index
    assert_response :success
  end


  test "should get roadmap without being logged on" do
    get :roadmap
    assert_response :success
  end

  test "should cancel question update and redirect to question page" do
    statement = Question.first
    session[:last_statement] = statement.statement.id
    get :cancel
    assert_redirected_to question_url(statement)
  end

  test "should cancel proposal update and redirect to proposal page" do
    statement = Proposal.first
    session[:last_statement] = statement.statement.id
    get :cancel
    assert_redirected_to question_proposal_url(statement.parent, statement)
  end

  test "should cancel improvement proposal update and redirect to improvement proposal page" do
    statement = ImprovementProposal.first
    session[:last_statement] = statement.statement.id
    get :cancel
    assert_redirected_to question_proposal_improvement_proposal_url(statement.root, statement.parent, statement)
  end
  
end
