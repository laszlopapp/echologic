class ProposalsController < StatementsController

  def parent
    Question.find(params[:question_id])
  end

end
