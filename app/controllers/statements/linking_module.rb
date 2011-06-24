module LinkingModule

  #
  # auto completion (gets all statements with certain terms in them)
  #
  # Method:   GET
  # Response: JS
  #
  def auto_complete_for_statement_title
    type = params[:type]
    linkable_types = type.classify.constantize.linkable_types.map(&:to_s)
    statement_nodes = search_statement_nodes :param => 'statement_id', 
                                             :search_term => params[:q],
                                             :types => linkable_types, 
                                             :limit => params[:limit] || 5, 
                                             :language_ids => [params[:code] || locale_language_id]
    documents = search_statement_documents(:statement_ids => statement_nodes.map(&:statement_id))
    
    content = statement_nodes.map(&:statement_id).uniq.map{ |id|
      "#{documents[id].title}|#{id}"
    }.join("\n")
    
    render :text => content
  end
  
  #
  # gets the statement data needed to fill the new statement node form and successfully link it with the statement (calls link_statement)
  #
  # Method:   GET
  # Response: JSON
  #
  def link_statement_node
    @statement = @statement_node.statement
    link_statement
  end
  
  
  #
  # gets the statement data needed to fill the new statement node form and successfully link it with the statement
  #
  # Method:   GET
  # Response: JSON
  #
  def link_statement
    @statement ||= Statement.find(params[:id])
    @statement_document ||= @statement.document_in_language(params[:code]||locale_language_id)
    @content = {:id => @statement.id,
                :title => @statement_document.title,
                :editorial_state => @statement.editorial_state_id, 
                :tags => @statement.topic_tags, 
                :text => @statement_document.text}
    if @statement.has_data?
      @content[:content_type] = @statement.info_type.code
      @content[:external_url] = @statement.external_url.info_url
    end
    render :json => @content.to_json 
  end
end