class Users::WebAddressController < ApplicationController

  before_filter :require_user

  access_control do
    allow logged_in
  end

  # Show the web profile with the given id.
  # method: GET
  def show
    @web_address = WebAddress.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js do
        replace_content(dom_id(@web_address), :partial => 'web_address')
      end
    end
  end

  # Show the new template for web profiles. Currently unused.
  # method: GET
  def new
    @web_address = WebAddress.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # Show the edit template for the specified web profile.
  # method: GET
  def edit
    @user = @current_user
    @web_address = WebAddress.find(params[:id])

    respond_to do |format|
      format.js do
        replace_content(dom_id(@web_address), :partial => 'edit')
      end
    end
  end

  # Create new web profile for the current user.
  # method: POST
  def create
    @web_address = WebAddress.new(params[:web_address])
    @web_address.user_id = @current_user.id

    respond_to do |format|
      format.js do
        if @web_address.save
          render :template => 'users/profile/create_object', :locals => { :object => @web_address }
        else
          show_error_messages(@web_address)
        end
      end
    end
  end

  # Update the web profiles attributes
  # method: PUT
  def update
    @web_address = WebAddress.find(params[:id])

    respond_to do |format|
      format.js do
        if @web_address.update_attributes(params[:web_address])
          replace_content(dom_id(@web_address), :partial => @web_address)
        else
          show_error_messages(@web_address)
        end
      end
    end
  end

  # Remove the web profile specified through id
  # method: DELETE
  def destroy
    @web_address = WebAddress.find(params[:id])
    id = @web_address.id
    @web_address.destroy

    respond_to do |format|
      format.js do
        remove_container "web_address_#{id}"
      end
    end
  end

end
