class DiscussionsController < StatementsController

  # action: my discussions page
  def my_discussions
    @page     = params[:page]  || 1

    discussions_not_paginated = Discussion.by_creator(current_user).by_creation

    session[:roots] = discussions_not_paginated.map(&:id)

    @discussions = discussions_not_paginated.paginate(:page => @page, :per_page => 5)
    @statement_documents = search_statement_documents(@discussions.map(&:statement_id),
                                                      @language_preference_list)

    respond_to_js :template => 'statements/discussions/my_discussions', :template_js => 'statements/discussions/my_discussions'
  end


  # action: publish a statement
  def publish
    begin
      StatementNode.transaction do
        @statement_node.publish
        respond_to do |format|
          if @statement_node.save
            EchoService.instance.published(@statement_node)
            format.js do
              set_info("discuss.statements.published")
              show_info_messages do |page|
                if params[:in] == 'summary'
                  page.redirect_to(url_for(@statement_node))
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
              show_error_messages(@statement_node)
            end
          end
        end
      end
    rescue Exception => e
      log_message_error(e, "Error publishing statement node '#{@statement_node.id}'.") do |format|
        if params[:in] == 'summary'
          format.html { flash_error and redirect_to url_for(@statement_node) }
        else
          format.html { flash_error and redirect_to my_discussions_url }
        end
      end
    else
      log_message_info("Statement node '#{@statement_node.id}' has been published sucessfully.")
    end
  end


  protected
 
  #returns the handled statement type symbol
  def statement_node_symbol
    :discussion
  end

  # returns the statement_node class, corresponding to the controllers name
  def statement_node_class
    Discussion
  end
end
