class QuestionsController < StatementsController


  def my_discussions
    @page     = params[:page]  || 1
    @language_preference_list = language_preference_list
    @statement_nodes = Question.by_creator(current_user).paginate(:page => @page, :per_page => 5)
    respond_to do |format|
      format.html {render :template => 'statements/questions/my_discussions'}
      format.js {render :template => 'statements/questions/discussions'}
    end
  end

  def parent
    nil
  end

  def publish
    @statement_node.publish
    respond_to do |format|
      format.js do
        if @statement_node.save
          set_info("discuss.statements.published")
          @language_preference_list = language_preference_list
          render_with_info do |p|
            p.replace(dom_id(@statement_node), :partial => 'statements/questions/discussion')
          end
        else
          show_error_messages(@statement_node)
        end
      end
    end
  end
end
