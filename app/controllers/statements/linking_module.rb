module LinkingModule

  #
  # auto completion (gets all statements with certain terms in them)
  #
  # Method:   GET
  # Response: JS
  #
  def auto_complete_for_statement_title
    statements = search_statements :param => 'id', :search_term => params[:q], :limit => params[:limit] || 5, :language_ids => [params[:code]||locale_language_id]
    documents = search_statement_documents(:statement_ids => statements.map(&:id))
    
    content = statements.map{ |statement|
      "#{documents[statement.id].title}|#{statement.id}"
    }.join("\n")
    
    render :text => content
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
    @content = {:editorial_state => @statement.editorial_state_id, 
                :tags => @statement.topic_tags, 
                :text => @statement_document.text}
    render :json => @content.to_json 
  end
end