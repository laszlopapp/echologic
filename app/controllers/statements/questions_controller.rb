class QuestionsController < StatementsController

  def my_discussions
    @page     = params[:page]  || 1
    @current_language_keys = current_language_keys
    @statements = Question.by_creator(current_user).paginate(:page => @page, :per_page => 5)
    respond_to do |format|
      format.html {render :template => 'statements/questions/my_discussions'}
    end
  end
end
