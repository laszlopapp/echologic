class Users::ConcernmentsController < ApplicationController

  before_filter :require_user

  helper :profile

  access_control do
    allow logged_in
  end

  # Generate auto completion based on tag values in the database. Load only 5
  # suggestions a time.
  auto_complete_for :tag, :value, :limit => 5

  # Create a new concernment connection for a user and a given topic with the
  # sort of concernment specified.
  #
  # Method:   POST
  # Params:   tag_value: string, user_id: integer, sort: integer
  # Response: JS
  #
  def create
    previous_completeness = current_user.profile.percent_completed
    @concernments = Concernment.create_for(params[:tag][:value].split(','), params[:concernment].merge(:user_id => current_user.id))
    current_completeness = @concernments.first.profile.percent_completed
    set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness
               
                    
    @sort = params[:concernment][:sort]
    
    
    respond_to do |format|
      format.js do
         render_with_info do |p|           
           p.insert_html :bottom, "concernments_#{@sort}", :partial => "users/concernments/concernment", :collection => @concernments, :locals => {:new => true}
           p.visual_effect :appear, dom_id(@concernments.last)           
         end
      end      
    end
  end

  # Remove a specified concernment.
  #
  # Method:   DELETE
  # Params:   id:integer
  # Response: JS
  #
  def destroy
    @concernment = Concernment.find(params[:id])
    previous_completeness = @concernment.profile.percent_completed
    @concernment.destroy
    current_completeness = @concernment.profile.percent_completed
    set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness

    respond_to do |format|
      format.js do
        # sorry, but this was crap. you can't add additional js actions like this...
        # either use a rjs, a js, or a render :update block
        # remove_container("concernment_#{params[:id]}")
        render_with_info do |p|
          p.remove dom_id(@concernment)
        end
        #render :template => 'users/profile/remove_object', :locals => { :object => @concernment }
      end
    end
  end
end
