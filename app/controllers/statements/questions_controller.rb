class QuestionsController < StatementsController

  
  # action: my discussions page
  def my_discussions
    @page     = params[:page]  || 1
    @statement_nodes = Question.by_creator(current_user).paginate(:page => @page, :per_page => 6)
    @statement_documents = search_statement_documents(@statement_nodes.map{|s|s.statement_id}, @language_preference_list)
    respond_to do |format|
      format.html {render :template => 'statements/questions/my_discussions'}
      format.js {render :template => 'statements/questions/discussions'}
    end
  end

  
  # action: publish a statement
  def publish
    @statement_node.publish
    @statement_documents = search_statement_documents([@statement_node.statement_id], @language_preference_list)
    respond_to do |format|
      format.js do
        if @statement_node.save
          set_info("discuss.statements.published")
          render_with_info do |p|
            p.replace(dom_id(@statement_node), :partial => 'statements/questions/discussion')
          end
        else
          show_error_messages(@statement_node)
        end
      end
    end
  end
  
  
  protected
  # return a possible parent, in this case question doesn't have a parent
  def parent
    nil
  end
  
  #returns the handled statement type symbol
  def statement_node_symbol
    :question
  end
  
  # returns the statement_node class, corresponding to the controllers name
  def statement_node_class
    Question
  end
  
  def root_symbol
    nil
  end
end
