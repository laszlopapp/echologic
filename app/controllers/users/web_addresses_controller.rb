class Users::WebAddressesController < ApplicationController
  helper :profile

  before_filter :fetch_web_address, :except => [:new,:create]

  access_control do
    allow logged_in
  end

  # Show the web profile with the given id.
  # method: GET
  def show
    render_web_address :partial => 'web_address'
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
    render_web_address :partial => 'edit'
  end

  # Create new web profile for the current user.
  # method: POST
  def create
    begin
      @web_address = WebAddress.new(params[:web_address].merge({:user => @current_user}))

      @before_completeness = @web_address.percent_completed
      respond_to do |format|
        format.js do
          if @web_address.save
            @after_completeness = @web_address.percent_completed
            set_info("discuss.messages.new_percentage", :percentage => @after_completeness) if @before_completeness != @after_completeness
            show_info_messages do |p|
              p.insert_html :bottom, 'web_address_list', :partial => 'users/web_addresses/web_address'
              p << "$('#new_web_address').reset();"
  	          p << "$('#web_address_type_id').focus();"
            end
          else
            show_error_messages(@web_address)
          end
        end
      end
    rescue Exception => e
      log_message_error(e, "Error creating web address.")
    else
      log_message_info("Web address has been created sucessfully.")
    end
  end

  # Update the web profiles attributes
  # method: PUT
  def update
    begin
      respond_to do |format|
        format.js do
          if @web_address.update_attributes(params[:web_address])
            replace_content(dom_id(@web_address), :partial => @web_address)
          else
            show_error_messages(@web_address)
          end
        end
      end
    rescue Exception => e
      log_message_error(e, "Error updating web address '#{@web_address.id}'.")
    else
      log_message_info("Web address '#{@web_address.id}' has been updated sucessfully.")
    end
  end

  # Remove the web profile specified through id
  # method: DELETE
  def destroy
    begin
      @before_completeness = @web_address.percent_completed
      @web_address.destroy
      @after_completeness = @web_address.percent_completed
      set_info("discuss.messages.new_percentage", :percentage => @after_completeness) if @before_completeness != @after_completeness

      respond_to do |format|
        format.js do

          # sorry, but this was crap. you can't add additional js actions like this...
          # either use a rjs, a js, or a render :update block
          #remove_container "web_profile_#{id}"
          show_info_messages do |p|
            p.remove dom_id(@web_address)
          end
        end
      end
    rescue Exception => e
      log_message_error(e, "Error deleting web address '#{@web_address.id}'.")
    else
      log_message_info("Web address '#{@web_address.id}' has been deleted sucessfully.")
    end
  end

  protected

  def fetch_web_address
    @web_address = WebAddress.find(params[:id]) || WebAddress.new(params[:web_address].merge({:user => @current_user}))
  end

  def render_web_address(opts={})
    respond_to do |format|
      format.js do
        replace_content(dom_id(@web_address), :partial => opts[:partial])
      end
    end
  end
end
