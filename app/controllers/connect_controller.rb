class ConnectController < ApplicationController

  before_filter :require_user

  # if the users profile is not fullfilled, we display a message and won't let him into the other users profiles 

  # Show the connect page
  # method: GET
  def show
    @value    = params[:value] || ""
    @sort     = params[:sort]  || ""
    @page     = params[:page]  || 1
    @profiles = Profile.search_profiles(@sort, @value.split(' ').first)

    if @value.split(' ').size > 1
       for value in @value.split(' ')[1..-1] do
        @profiles &= Profile.search_profiles(@sort, value)
      end
    end

    @profiles = @profiles.paginate(:page => @page, :per_page => 6)

    # decide which rjs template to render, based on if a search query was entered
    # atm we don't want to toggle profile details when we paginate, but when we search
    # TODO: if search and paginate logic drift more apart, consider seperate controller actions

    respond_to do |format|
      format.html { render :template => 'connect/search' }
      format.js   { render :template => 'connect/search' }
    end
  end

  # Render the roadmap template.
  # method: GET
  def roadmap
    respond_to do |format|
      format.html # roadmap.html.erb
    end
  end
end
