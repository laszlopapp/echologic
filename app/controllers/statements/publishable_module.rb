module PublishableModule


  ###########
  # ACTIONS #
  ###########

  # Shows all current users' existing discussions
  #
  # Method:   GET
  # Params:   value: string, id (category): string
  # Response: JS
  #
  def my_discussions
    @page     = params[:page]  || 1

    discussions_not_paginated = current_user.get_my_discussions

    @discussions = discussions_not_paginated.paginate(:page => @page, :per_page => 5)
    @statement_documents = search_statement_documents(@discussions.map(&:statement_id),
                                                      @language_preference_list)

    respond_to_js :template => 'statements/discussions/my_discussions', :template_js => 'statements/discussions/my_discussions'
  end


  # Shows all the existing debates according to the given search string and a possible category.
  #
  # Method:   GET
  # Params:   value: string, id (category): string
  # Response: JS
  #
  def category
    @value    = params[:value] || ""
    @page     = params[:page]  || 1

    statement_nodes_not_paginated = search_statement_nodes(:search_term => @value,
                                                           :language_ids => @language_preference_list,
                                                           :show_unpublished => current_user &&
                                                                                current_user.has_role?(:editor))

    @count    = statement_nodes_not_paginated.size
    @statement_nodes = statement_nodes_not_paginated.paginate(:page => @page,
                                                              :per_page => 6)
    @statement_documents = search_statement_documents(@statement_nodes.map(&:statement_id), @language_preference_list)

    respond_to_js :template => 'statements/discussions/index',
                  :template_js => 'statements/discussions/discussions'
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
          if @statement_node.save
            EchoService.instance.published(@statement_node)
            format.js do
              set_info("discuss.statements.published")
              render_with_info do |page|
                if params[:in] == 'summary'
                  page.remove 'edit_button', 'publish_button'
                else
                  @statement_documents =
                    search_statement_documents([@statement_node.statement_id])
                  page.replace(dom_id(@statement_node),
                               :partial => 'statements/discussions/my_discussion',
                               :locals => {:my_discussion => @statement_node ,
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
          flash_error and redirect_to my_discussions_url
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