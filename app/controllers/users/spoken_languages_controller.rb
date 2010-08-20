class Users::SpokenLanguagesController < ApplicationController

  before_filter :require_user
  before_filter :fetch_spoken_language, :except => [:new, :create]

  access_control do
    allow logged_in
  end

  # Show the spoken language with the given id.
  # method: GET
  def show
    render_spoken_language :partial => 'spoken_language'
  end

  # Show the new template for spoken languages. Currently unused.
  # method: GET
  def new
    @spoken_language = SpokenLanguage.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # Show the edit template for the specified spoken language.
  # method: GET
  def edit
    @user = @current_user
    render_spoken_language :partial => 'edit'
  end

  # Create new spoken language for the current user.
  # method: POST
  def create
    @spoken_language = SpokenLanguage.new(params[:spoken_language].merge({:user => @current_user}))
    previous_completeness = @spoken_language.percent_completed
    respond_to do |format|
      format.js do
        if @spoken_language.save
          current_completeness = @spoken_language.percent_completed
          set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness

          render_with_info do |p|
            p.insert_html :bottom, 'spoken_language_list', :partial => 'users/spoken_languages/spoken_language'
            p << "$('#new_spoken_language').reset();"
            p << "$('#spoken_language_language').focus();"
          end
        else
          show_error_messages(@spoken_language)
        end
      end
    end
  end

  # Update the spoken languages attributes
  # method: PUT
  def update

    respond_to do |format|
      format.js do
        if @spoken_language.update_attributes(params[:spoken_language])
          replace_content(dom_id(@spoken_language), :partial => @spoken_language)
        else
          show_error_messages(@spoken_language)
        end
      end
    end
  end

  # Remove the spoken language specified through id
  # method: DELETE
  def destroy

    id = @spoken_language.id

    previous_completeness = @spoken_language.percent_completed
    @spoken_language.destroy
    current_completeness = @spoken_language.percent_completed
    set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness

    respond_to do |format|
      format.js do

        # sorry, but this was crap. you can't add additional js actions like this...
        # either use a rjs, a js, or a render :update block
        #remove_container "web_address_#{id}"
        render_with_info do |p|
          p.remove dom_id(@spoken_language)
        end
      end
    end
  end
  
  private
  def fetch_spoken_language
    @spoken_language = SpokenLanguage.find(params[:id])
  end
  
  def render_spoken_language(opts={})
    respond_to do |format|
      format.js do
        replace_content(dom_id(@spoken_language), :partial => opts[:partial])
      end
    end
  end
end
