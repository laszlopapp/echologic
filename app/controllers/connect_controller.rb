class ConnectController < ApplicationController

  # Show the connect page
  # method: GET
  def show
    @value    = params[:search_terms] || ""
    @sort     = params[:sort]  || ""
    @page     = params[:page]  || 1
    @profiles = Profile.search_profiles(@sort, @value)

    @profiles = @profiles.paginate(:page => @page, :per_page => 6)

    # decide which rjs template to render, based on if a search query was entered
    # atm we don't want to toggle profile details when we paginate, but when we search
    # TODO: if search and paginate logic drift more apart, consider seperate controller actions

    respond_to_js :template => 'connect/search', :template_js => 'connect/search'
  end

  # Render the roadmap template.
  # method: GET
  def roadmap
    respond_to do |format|
      format.html # roadmap.html.erb
    end
  end
end
