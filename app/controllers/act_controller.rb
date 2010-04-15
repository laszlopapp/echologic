class ActController < ApplicationController

  before_filter :require_user
  
  # GET /act
  def roadmap
    respond_to do |format|
      format.html
    end
  end

end
