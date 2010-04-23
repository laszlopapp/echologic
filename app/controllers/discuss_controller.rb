class DiscussController < ApplicationController

  before_filter :store_location, :only => [:index]
  
  # GET /discuss
  def roadmap
    respond_to do |format|
      format.html
    end
  end
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  # processes a cancel request, and redirects back to the last shown statement
  def cancel
    @statement = Statement.find(session[:last_statement])
    #redirect_to question_proposal_url(@statement.parent, @statement)
    case @statement.class.name
    when "Question"
      redirect_to question_url(@statement)
    when "Proposal"
      redirect_to question_proposal_path(@statement.parent, @statement)
    when "ImprovementProposal"
      redirect_to question_proposal_improvement_proposal_url(@statement.root, @statement.parent, @statement)
    end
  end

end
