class ApiController < ApplicationController
  
  
  def oembed
    respond_to do |format|
      begin
        @data = filter_url(params[:url])
        
        
        
        if @data[:status]
          format.html {render :inline => @data.to_json}
        else 
          format.html {render :inline => @data.to_json}
        end
        
      rescue Exception => e
        format.json{render :json => not_found}
      end
    end
  end
  
  private
  
  def filter_url(url)
    return not_found if url.blank?
    if elems = is_discuss_search_path?(url)
      {:command => "discuss_search", :search_terms => elems[4]}
    elsif elems = is_statement_node_path?(url)
      statement_node = StatementNode.find(elems[3])
      {:command => "statement_node", :statement_node => statement_node}
    end
  end
  
  def not_found
    {:status => 404, :message => "Not Found"}
  end
  
  def is_discuss_search_path?(url)
    url.match(%r(^(http.?://#{ECHO_HOST})?(/\w{2})?/?discuss/search(.*search_terms=([^\?]*).*)?))
  end
  
  def is_statement_node_path?(url)
    url.match(%r(^(http.?://#{ECHO_HOST})?(/\w{2})?/?statement/(\d*).*)) 
  end
  
end
