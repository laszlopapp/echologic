class Users::MembershipsController < ApplicationController

  before_filter :require_user
  before_filter :fetch_membership, :except => [:new, :create]
  
  helper :profile

  access_control do
    allow logged_in
  end

  # Shows the membership identified through params[:id]
  # method: GET
  def show
    render_membership :partial =>'membership'
  end

  # Render the new membership template. Currently unused.
  # method: GET
  def new
    @membership = Membership.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # Render the edit membership template. Currently only respond to JS.
  # method: GET
  def edit
    render_membership :partial => 'edit'
  end

  # Create a new membership with the given params. Show error messages
  # through javascript if something fails.
  # method: POST
  def create

    @membership = Membership.new(params[:membership].merge(:user_id => current_user.id))
    previous_completeness = @membership.percent_completed

    respond_to do |format|
      format.js do
        if @membership.save
          current_completeness = @membership.percent_completed
          set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness
          render_with_info do |p|
            p.insert_html :bottom, 'membership_list', :partial => 'users/memberships/membership'
            p << "$('#membership_organisation').focus();"
          end
        else
          show_error_messages(@membership)
        end
      end
    end
  end

  # Update the membership attributes.
  # method: PUT
  def update

    respond_to do |format|
      format.js do
        if @membership.update_attributes(params[:membership].merge(:user_id => current_user.id))
          replace_content(dom_id(@membership), :partial => 'membership')
        else
          show_error_messages(@membership)
        end
      end
    end
  end

  # Destroy the membership specified through params[:id]
  # method: DELETE
  def destroy
    id = @membership.id

    previous_completeness = @membership.percent_completed
    @membership.destroy
    current_completeness = @membership.percent_completed
    set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness

    respond_to do |format|
      format.js do
        # sorry, but this was crap. you can't add additional js actions like this...
        # either use a rjs, a js, or a render :update block
        render_with_info do |p|
          p.remove dom_id(@membership)
        end
      end
    end
  end
  
  private
  
  def fetch_membership
    @membership = Membership.find(params[:id])
  end
  
  def render_membership(opts={})
    respond_to do |format|
      format.js do
        replace_content(dom_id(@membership), :partial => opts[:partial])
      end
    end
  end
end
