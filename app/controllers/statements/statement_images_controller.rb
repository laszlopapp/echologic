class StatementImagesController < ApplicationController
  
  verify :method => :get, :only => [:edit, :reload]
  verify :method => :put, :only => [:update]
  
  before_filter :fetch_statement_image
  before_filter :fetch_statement_node, :except => [:update]
  
  access_control do
    allow :admin, :editor, logged_in
  end
  
  #
  # Renders a form to insert the current statement's image.
  #
  # Method:   GET
  # Params:   id: integer, node_id: integer
  # Response: JS
  #
  def edit
    respond_to_js :template_js => 'statement_images/edit'
  end
  
  
  #
  # Updates statement's image
  #
  # Method:   POST
  # Params:   statement_image: hash
  # Response: JS
  #
  def update
    @statement_image.update_attributes(params[:statement_image])
  end
  
  
  #
  # After uploading the image, this has to be reloaded.
  # Reloading:
  #  1. login_container with users picture as profile link
  #  2. picture container of the profile
  #
  # Method:   GET
  # Response: JS
  #
  def reload
    respond_to do |format|
      if @statement_image.image.exists? and @statement_image.image.updated_at != params[:date].to_i
        set_info 'discuss.messages.image_uploaded', :type => I18n.t("discuss.statements.types.#{@statement_node.class.name.underscore}")
        format.js {
          render_with_info do |page|
            page << "$('#statements div.#{dom_class(@statement_node)} .image_container .image').replaceWith('#{render :partial => 'statement_images/image'}')"
            page << "$('#statements div.#{dom_class(@statement_node)} .image_container .upload_link').remove()" if !current_user or !current_user.may_update_image?(@statement_node)
          end
        }
      else
        format.js { set_error 'discuss.statements.upload_image.error' and render_with_error }
      end
    end
  end
  
  private
  
  def fetch_statement_image
    @statement_image = StatementImage.find(params[:id])
  end
  
  def fetch_statement_node
    @statement_node = StatementNode.find(params[:node_id])
  end
end
