class ApiController < ApplicationController
  verify :method => :get, :only => [:oembed]
  
  def oembed
    respond_to do |format|
      begin
        @data = filter_url(params[:url])
        @data[:provider_name] = "echo"
        @data[:provider_url] = "http://echo.to"
        @data[:type] = "rich"
        @data[:width] = params[:maxwidth] || "860px"
        @data[:height] = params[:maxheight] || "1000px"
        @data[:version] = "1.0"
        
        
# ONLY FOR TESTING        format.html {render :inline => @data.to_json}
        format.json {render :json => @data.to_json}
        format.xml {render :xml => not_implemented}
        
      rescue Exception => e
        format.json{render :json => not_found}
      end
    end
  end
  
  private
  
  def filter_url(url)
    return not_found if url.blank?
    if elems = is_discuss_search_path?(url)
      {:command => "discuss_search", :search_terms => elems[4],
       :title => "Discussions for #{elems[4]}"}
    elsif elems = is_statement_node_path?(url)
      statement_node = StatementNode.find(elems[3])
      language_ids = elems[2].nil? ? [] : [Language[elems[2]].id]
      language_ids << statement_node.original_language.id
      statement_document = statement_node.document_in_preferred_language(language_ids)
      {:command => "statement_node", :title => statement_document.title}
    end
  end
  
  def not_found
    {:status => 404, :message => "Not Found"}
  end
  
  def not_implemented
    {:status => 501, :message => "Not Implemented"}
  end
  
  def is_discuss_search_path?(url)
    url.match(%r(^(http.?://#{ECHO_HOST})?(/\w{2})?/?discuss/search(.*search_terms=([^\?]*).*)?))
  end
  
  def is_statement_node_path?(url)
    url.match(%r(^(http.?://#{ECHO_HOST})?(/\w{2})?/?statement/(\d*).*)) 
  end
  
end
