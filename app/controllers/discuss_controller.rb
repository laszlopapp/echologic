class DiscussController < ApplicationController

  auto_complete_for :tag, :value, :limit => 20 do |tags|
    @@tag_filter.call %w(*), tags
   end

  # GET /discuss
  def roadmap
    respond_to do |format|
      format.html
    end
  end

  def index
    respond_to do |format|
      format.html
    end
  end

  # processes a cancel request, and redirects back to the last shown statement_node
  def cancel
    @statement_node = StatementNode.find(session[:last_statement_node])
    redirect_to @statement_node
  end

end
