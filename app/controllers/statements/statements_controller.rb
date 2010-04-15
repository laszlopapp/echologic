class StatementsController < ApplicationController
  helper :echo
  include EchoHelper

  # remodelling the RESTful constraints, as a default route is currently active
  # FIXME: the echo and unecho actions should be accessible via PUT/DELETE only,
  #        but that is currently undoable without breaking non-js requests. A
  #        solution would be to make the "echo" button a real submit button and
  #        wrap a form around it.
  verify :method => :get, :only => [:index, :show, :new, :edit, :category]
  verify :method => :post, :only => :create
  verify :method => :put, :only => [:update]
  verify :method => :delete, :only => [:destroy]

  # the order of these filters matters. change with caution.
  before_filter :fetch_statement, :only => [:show, :edit, :update, :echo, :unecho, :destroy]
  before_filter :fetch_category, :only => [:index, :new, :show, :edit, :update, :destroy]

  before_filter :require_user, :except => [:index, :category, :show]
  
  # as discussions are public now, it's neccessary so save where we are, to redirect the user back after login
  before_filter :store_location, :only => [:index, :category, :show]
  
  # make custom URL helper available to controller
  include StatementHelper

  # authlogic access control block
  access_control do
    allow :editor
    allow anonymous, :to => [:index, :show, :category]
    allow logged_in, :only => [:index, :show, :echo, :unecho]
    allow logged_in, :only => [:new, :create], :unless => :is_question?
    allow logged_in, :only => [:edit, :update], :if => :may_edit?
    allow logged_in, :only => [:destroy], :if => :may_delete?
  end

  # FIXME: I tink this method is never used - it should possibly do nothing, or redirect to category...
  def index
    @statements = statement_class.published(current_user.has_role?(:editor)).by_supporters.paginate(statement_class.default_scope.merge(:page => @page, :per_page => 6))
    respond_to do |format|
      format.html { render :template => 'questions/index' }
    end

  end

  # TODO use find or create category tag?
  # displays all questions in a category
  def category
    @value    = params[:value] || ""
    @page     = params[:page]  || 1
   
    if @value.blank?
      #step 1.0: get the class name in order to get all the possible results
      statements_not_paginated = statement_class
    else  
      #step 1.01: search for first string
      statements_not_paginated = search(@value.split(' ').first)
      #statements_not_paginated = statement_class.search(@value.split(' ').first)    
      #step 1.10: search for remaining strings
      if @value.split(' ').size > 1
         for value in @value.split(' ')[1..-1] do

           statements_not_paginated &= search(value)

        end
      end
    end
    
   
    #step 2: filter by category, if there is one 
    statements_not_paginated = statements_not_paginated.from_category(params[:id]) if params[:id]
    
    statements_not_paginated = statements_not_paginated.published(current_user && current_user.has_role?(:editor)).by_supporters.by_creation
    
    @count    = statements_not_paginated.count
    @category = Tag.find_or_create_by_value(params[:id])
    
    @statements = statements_not_paginated.paginate(:page => @page, :per_page => 6)
   
    respond_to do |format|
      format.html {render :template => 'questions/index'}
      format.js {
        replace_container('question_container', :partial => 'questions/questions')
      }
    end
  end

  def search (value)
    statement_class.find_by_title(value)    
  end


  # TODO visited! throws error with current fixtures.

  def show
    current_user.visited!(@statement) if current_user
  
    # store last statement (for cancel link)
    session[:last_statement] = @statement.id
    
    # prev / next functionaliy
    unless @statement.children.empty?
      child_type = ("current_" + @statement.class.expected_children.first.to_s.underscore).to_sym
      session[child_type] = @statement.children.by_supporters.collect { |c| c.id }
    end
    
    # when creating an issue, we save the flash message within the session, to be able to display it hete
    if session[:last_info]
      @info = session[:last_info]
      flash_info
      session[:last_info] = nil
    end

    # find alle child statements, which are published (except user is an editor) sorted by supporters count, and paginate them
    @page = params[:page] || 1
    @children = @statement.children.published(current_user && current_user.has_role?(:editor)).by_supporters.paginate(Statement.default_scope.merge(:page => @page, :per_page => 5))
    respond_to do |format|
      format.html { 
        render :template => 'statements/show' } # show.html.erb
      format.js   { 
        render :template => 'statements/show' } # show.js.erb
    end
  end

  # Called if user supports this statement. Updates the support field in the corresponding
  # echo object.
  def echo
    return if @statement.question?
    current_user.supported!(@statement)
    respond_to do |format|
      format.html { redirect_to @statement }
      format.js { render :template => 'statements/echo' }
    end
  end

  # Called if user doesn't support this statement any longer. Sets the supported field
  # of the corresponding echo object to false.
  def unecho
    return if @statement.question?
    current_user.echo!(@statement, :supported => false)
    respond_to do |format|
      format.html { redirect_to @statement }
      format.js { render :template => 'statements/echo' }
    end
  end

  # renders form for creating a new statement
  def new
    @statement ||= statement_class.new(:parent => parent, :category_id => @category.id)
    # TODO: right now users can't select the language they create a statement in, so current_user.languages_keys.first will work. once this changes, we're in trouble - or better said: we'll have to pass the language_id as a param
    @statement.create_statement(:original_language_id => current_user.language_keys.first)
    @statement.add_statement_document
    respond_to do |format|
      format.html { render :template => 'statements/new' }
      format.js {
        render :update do |page|
          page.replace(@statement.kind_of?(Question) ? 'questions_container' : 'children', :partial => 'statements/new')
          page.replace('context', :partial => 'statements/context', :locals => { :statement => @statement.parent})          
          page.replace('summary', :partial => 'statements/summary', :locals => { :statement => @statement.parent}) 
          page.replace('discuss_sidebar', :partial => 'statements/sidebar', :locals => { :statement => @statement.parent}) 
          page.replace('navigator_container', :partial => 'statements/navigator', :locals => { :statement => @statement.parent})
        end
      }
    end
  end

  # actually creates a new statement
  def create
    attrs = params[statement_class_param]
    attrs[:state] = StatementNode.state_lookup[:published] unless statement_class == Question
    @statement = statement_class.new(attrs)
    @statement.creator = @statement.document.author = current_user

    respond_to do |format|
      if @statement.save
        set_info("discuss.messages.created", :type => @statement.class.display_name)
        current_user.supported!(@statement)
        # render parent statement after creation, if any
        # @statement = @statement.parent if @statement.parent
        format.html { flash_info and redirect_to url_for(@statement) }
        format.js   {
          session[:last_info] = @info # save @info so it doesn't get lost during redirect
          render :update do |page|
            page << "window.location.replace('#{url_for(@statement)}');"
          end
        }
      else
        set_error(@statement.document)
        format.html { flash_error and render :template => 'statements/new' }
        format.js   { show_error_messages(@statement.document) }
      end
    end
  end

  # renders a form to edit statements
  def edit
    respond_to do |format|
      format.html { render :template => 'statements/edit' }
      format.js { replace_container('summary', :partial => 'statements/edit') }
    end
  end

  # actually update statements
  def update
    attrs = params[statement_class_param]
    attrs[:statement_document][:author] = current_user
    attrs_doc = attrs.delete(:statement_document)
    respond_to do |format|
      if @statement.update_attributes!(attrs) && @statement.translated_document(current_user.language_keys).update_attributes!(attrs_doc)
        set_info("discuss.messages.updated", :type => @statement.class.human_name)
        format.html { flash_info and redirect_to url_for(@statement) }
        format.js   { show }
      else
        set_error(@statement.document)
        format.html { flash_error and redirect_to url_for(@statement) }
        format.js   { show_error_messages }
      end
    end
  end

  # destroys a statement
  def destroy
    @statement.destroy
    set_info("discuss.messages.deleted", :type => @statement.class.human_name)
    flash_info and redirect_to :controller => 'questions', :action => :category, :id => @category.value
  end
  
  # processes a cancel request, and redirects back to the last shown statement
  def cancel
    redirect_to url_f(Statement.find(session[:last_statement]))
  end

  #
  # PRIVATE
  #
  private

  def fetch_statement
    @statement ||= statement_class.find(params[:id]) if params[:id].try(:any?) && params[:id] =~ /\d+/
  end

  # Fetch current category based on various factors.
  # If the category is supplied as :id, render action 'index' no matter what params[:action] suggests.
  def fetch_category
    @category = if params[:category] # i.e. /discuss/questions/...?category=<tag>
                  Tag.find_by_value(params[:category])
                elsif params[:category_id] # happens on form-based POSTed requests
                  Tag.find(params[:category_id])
                elsif parent || (@statement && ! @statement.new_record?) # i.e. /discuss/questions/<id>
                  @statement.try(:category) || parent.try(:category)
                else
                  nil
                end or redirect_to :controller => 'discuss', :action => 'index'
  end

  # returns the statement class, corresponding to the controllers name
  def statement_class
    params[:controller].singularize.camelize.constantize
  end

  # Checks if the current controller belongs to a question
  # FIXME: isn't this possible to solve over statement.quesion? already?
  def is_question?
    params[:controller].singularize.camelize.eql?('Question')
  end

  def may_edit?
    current_user.may_edit?(@statement)
  end

  def may_delete?
    current_user.may_delete?(@statement)
  end

  def statement_class_param
    statement_class.name.underscore.to_sym
  end

  def parent
    statement_class.valid_parents.each do |parent|
      parent_id = params[:"#{parent.to_s.underscore.singularize}_id"]
      return parent.to_s.constantize.find(parent_id) if parent_id
    end ; nil
  end
end
