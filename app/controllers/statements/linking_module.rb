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
    
    parent_node = StatementNode.find(params[:parent_id])
    
    # Excluding content belonging to the same subtree
    joins = "LEFT JOIN statement_nodes_parents s_parents ON s_parents.id = s.id "
    conditions = ["(s_parents.parent_node_id != ? OR 
                   (s_parents.type = 'Question' AND s.root_id != ?) OR
                   (statement_nodes.root_id = ? AND statement_nodes.lft < ? AND statement_nodes.rgt > ?))", 
                   parent_node.id, parent_node.id, parent_node.root_id, parent_node.lft, parent_node.rgt]
    
    statement_nodes = search_statement_nodes :param => 'statement_id', 
                                             :search_term => params[:q],
                                             :types => linkable_types, 
                                             :limit => params[:limit] || 5, 
                                             :language_ids => [params[:code] || locale_language_id],
                                             :joins => joins,
                                             :node_conditions => [conditions]
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
    @type_to_link = params[:type].to_s.classify.constantize
    @parent_node = StatementNode.find(params[:parent_id])
    if @type_to_link.linkable_types.include? @statement_node.class.name.to_sym and 
      !@statement_node.parent_node.id.eql?(@parent_node.target_id) 
      link_statement
    else
      render :json => {:error => I18n.t("discuss.statements.cannot_be_linked")}
    end
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
    if @statement_document
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
    else
      render :json => {:error => I18n.t("discuss.statements.no_document_in_language")}
    end
  end
end