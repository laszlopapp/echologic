module PublishableModule


  ###########
  # ACTIONS #
  ###########

  # Shows all current users' existing questions
  #
  # Method:   GET
  # Params:   value: string, id (category): string
  # Response: JS
  #
  def my_questions
    @page     = params[:page]  || 1

    questions_not_paginated = Question.by_creator(current_user).by_creation

    @questions = questions_not_paginated.paginate(:page => @page, :per_page => 5)
    @statement_documents = search_statement_documents(@questions.map(&:statement_id),
                                                      @language_preference_list)

    respond_to_js :template => 'statements/questions/my_questions', :template_js => 'statements/questions/my_questions'
  end


  # Shows all the existing debates according to the given search string and a possible category.
  #
  # Method:   GET
  # Params:   value: string, id (category): string
  # Response: JS
  #
  def category
    @value    = params[:search_terms] || ""
    @page     = params[:page]  || 1
    @per_page = params[:per_page] || 6

    statement_nodes_not_paginated = search_statement_nodes(:search_term => @value,
                                                           :user => current_user,
                                                           :language_ids => @language_preference_list,
                                                           :show_unpublished => current_user &&
                                                                                current_user.has_role?(:editor))

    @count    = statement_nodes_not_paginated.count
    @statement_nodes = statement_nodes_not_paginated.paginate(:page => @page, :per_page => @per_page)
    @statement_documents = search_statement_documents(@statement_nodes.map(&:statement_id), @language_preference_list, 
                                            :select => "DISTINCT id, title, statement_id, language_id, current, text")

    respond_to_js :template => 'statements/questions/index',
                  :template_js => 'statements/questions/questions'
  end

  # publishes the statement
  #
  # Method:   PUT
  # Response: JS
  #
  def publish
    begin
      StatementNode.transaction do
        @statement_node.publish
        respond_to do |format|
          if @statement_node.statement.save
            @statement_node.statement.statement_nodes.each do |node|
              EchoService.instance.published(node)
            end
            format.js do
              set_info("discuss.statements.published")
              render_with_info do |page|
                if params[:in] == 'summary'
                  page << "$('#statements .#{dom_class(@statement_node)} .edit_text_button').remove();"
                  page << "$('#statements .#{dom_class(@statement_node)} .publish_text_button').remove();"
                else
                  @statement_documents =
                    search_statement_documents([@statement_node.statement_id])
                  page.replace(dom_id(@statement_node),
                               :partial => 'statements/questions/my_question',
                               :locals => {:my_question => @statement_node ,
                                           :statement_document => @statement_documents[@statement_node.statement_id]})
                end
              end
            end
          else
            format.js do
              set_error @statement_node and render_with_error
            end
          end
        end
      end
    rescue Exception => e
      log_message_error(e, "Error publishing statement node '#{@statement_node.id}'.") do
        if params[:in] == 'summary'
          flash_error and redirect_to statement_node_url(@statement_node)
        else
          flash_error and redirect_to my_questions_url
        end
      end
    else
      log_message_info("Statement node '#{@statement_node.id}' has been published sucessfully.")
    end
  end

  protected

  def is_publishable?
    @statement_node.publishable?
  end
end