class StatementsController < ApplicationController
  helper :echo
  include EchoHelper
  include StatementHelper
  

  # remodelling the RESTful constraints, as a default route is currently active
  # FIXME: the echo and unecho actions should be accessible via PUT/DELETE only,
  #        but that is currently undoable without breaking non-js requests. A
  #        solution would be to make the "echo" button a real submit button and
  #        wrap a form around it.
  verify :method => :get, :only => [:index, :show, :new, :edit, :category, :new_translation]
  verify :method => :post, :only => [:create]
  verify :method => :put, :only => [:update, :create_translation,:publish]
  verify :method => :delete, :only => [:destroy]

  # the order of these filters matters. change with caution.
  before_filter :fetch_statement_node, :only => [:show, :edit, :update, :echo, :unecho, :new_translation,:create_translation,:destroy,:publish]
  before_filter :require_user, :except => [:index, :category, :show]
 
  # authlogic access control block
  access_control do
    allow :editor
    allow anonymous, :to => [:index, :show, :category]
    allow logged_in, :only => [:index, :show, :echo, :unecho, :new, :create, :new_translation, :create_translation, :publish]
    allow logged_in, :only => [:edit, :update], :if => :may_edit?
    allow logged_in, :only => [:destroy], :if => :may_delete?
  end

  

  # Shows all the existing debates according to the given search string and a possible category.
  #
  # Method:   GET
  # Params:   value: string, id (category): string
  # Response: JS
  #
  def category
    @value    = params[:value] || ""
    @page     = params[:page]  || 1

    category = "##{params[:id]}" if params[:id]


    @language_preference_list = language_preference_list

    statement_nodes_not_paginated = search(@value, @language_preference_list,
                                           {:tag => category,
                                            :auth => (current_user && current_user.has_role?(:editor))})
                                            
    @count    = statement_nodes_not_paginated.size
    @statement_nodes = statement_nodes_not_paginated.paginate(:page => @page, :per_page => 6)

    respond_to do |format|
      format.html {render :template => 'statements/questions/index'}
      format.js {render :template => 'statements/questions/questions'}
    end
  end




  # Shows a selected statement
  #
  # Method:   GET
  # Params:   id: integer
  # Response: HTTP or JS
  #
  def show
    @statement_node.visited_by!(current_user) if current_user

    # store last statement (for cancel link)
    session[:last_statement_node] = @statement_node.id

    @language_preference_list = language_preference_list

    # prev / next functionality
    unless @statement_node.children.empty?
      child_type = ("current_" + @statement_node.class.expected_children.first.to_s.underscore).to_sym
      session[child_type] = @statement_node.children.by_supporters.collect { |c| c.id }
    end

    # Get document to show and redirect if not found
    @statement_document = @statement_node.translated_document(@language_preference_list)
    
    if @statement_document.nil?
      redirect_to(discuss_search_path)
      return
    end

    #test for special links
    @original_language_warning = @statement_node.not_original_language?(current_user,locale_language_id)
    @translation_permission = @statement_node.translatable?(current_user,params[:locale],@language_preference_list)

    # when creating an issue, we save the flash message within the session, to be able to display it here
    if session[:last_info]
      @info = session[:last_info]
      flash_info
      session[:last_info] = nil
    end

    # find all child statement_nodes, which are published (except user is an editor) sorted by supporters count, and paginate them
    @page = params[:page] || 1

    @children = @statement_node.sorted_children(current_user,@language_preference_list).paginate(
                                                StatementNode.default_scope.merge(:page => @page, :per_page => 5))
    
    respond_to do |format|
      format.html {render :template => 'statements/show' } # show.html.erb
      format.js   {render :template => 'statements/show' } # show.js.erb
    end
  end

  # Called if user supports this statement_node. Updates the support field in the corresponding
  # echo object.
  #
  # Method:   POST
  # Response: JS
  #
  def echo
    return if !@statement_node.echoable?
    @statement_node.supported_by!(current_user)
    current_user.find_or_create_subscription_for(@statement_node)
    @language_preference_list = language_preference_list
    respond_to do |format|
      format.html { redirect_to @statement_node }
      format.js { render :template => 'statements/echo' }
    end
  end

  # Called if user doesn't support this statement_node any longer. Sets the supported field
  # of the corresponding echo object to false.
  #
  # Method:   POST
  # Response: HTTP or JS
  #
  def unecho
    return if !@statement_node.echoable?
    current_user.echo!(@statement_node, :supported => false)
    current_user.delete_subscription_for(@statement_node)
    @language_preference_list = language_preference_list
    respond_to do |format|
      format.html { redirect_to @statement_node }
      format.js { render :template => 'statements/echo' }
    end
  end


  # Renders the new statement translation form when called
  #
  # Method:   GET
  # Response: JS
  #
  def new_translation
    @statement_document ||= @statement_node.translated_document(current_user.spoken_language_ids)
    @new_statement_document ||= @statement_node.add_statement_document({:language_id => locale_language_id})
    respond_to do |format|
      format.html { render :template => 'statements/translate' }
      format.js {render_new_translation}
    end
  end
  private
  def render_new_translation
    render :update do |page|
      page.replace('summary', :partial => 'statements/translate')
      page << "makeRatiobars();"
      page << "makeTooltips();"
      page << "roundCorners();"
    end
  end
  public

  # Creates a translation of a statement according to the fields from a form that was submitted
  #
  # Method:   POST
  # Params:   new_statement_document: hash
  # Response: JS
  #
  def create_translation
    attrs = params[statement_class_param]
    doc_attrs = attrs.delete(:new_statement_document).merge({:author_id => current_user.id, 
                                                             :language_id => locale_language_id})
    @new_statement_document = @statement_node.add_statement_document(doc_attrs)
    respond_to do |format|
      if @statement_node.save
        set_statement_node_info("discuss.messages.translated",@statement_node)
        @language_preference_list = language_preference_list
        @statement_document = @new_statement_document
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js   {render_create_translation(@statement_node,@statement_document)}
      else
        @statement_document = StatementDocument.find(doc_attrs[:translated_document_id])
        set_error(@new_statement_document)
        format.html { flash_error and render :template => 'statements/translate' }
        format.js   { show_error_messages(@new_statement_document) }
      end
    end
  end
  
  private
  def render_create_translation(statement_node,statement_document)
    render_with_info do |page|
      page.replace('context', 
                   :partial => 'statements/context', 
                   :locals => { :statement_node => statement_node})
      page.replace('summary', 
                   :partial => 'statements/summary', 
                   :locals => { :statement_node => statement_node, :statement_document => statement_document})
      page << "makeRatiobars();"
      page << "makeTooltips();"
    end
  end
  public
  # renders form for creating a new statement
  #
  # Method:   GET
  # Params:   parent_id: integer, root_id: integer
  # Response: JS
  #
  def new
    @statement_node ||= statement_node_class.new(:parent => parent, :root_id => params[:question_id])
    @statement_document ||= StatementDocument.new

    @tags = @statement_node.tags if @statement_node.taggable?

    @language_preference_list = language_preference_list
    @locale_language_id = locale_language_id
    # TODO: right now users can't select the language they create a statement in, so current_user.languages_keys.
    # first will work. once this changes, we're in trouble - or better said: we'll have to pass the language_id as a param
    respond_to do |format|
      format.html { render :template => 'statements/new' }
      format.js {render_new_statement_node @statement_node, @language_preference_list}
    end
  end
  private
  def render_new_statement_node(statement_node, language_preference_list)
    render :update do |page|
      if statement_node.kind_of?(Question)
        page.remove 'search_container'
        page.remove 'new_question'
        page.replace 'questions_container', :partial => 'statements/new'
        page.replace 'my_discussions', :partial => 'statements/new'
      else
        page.replace 'children', :partial => 'statements/new'
      end
      page.replace('summary',
                   :partial => 'statements/summary',
                   :locals => { :statement_node => statement_node.parent,
                                :statement_document => statement_node.parent.translated_document(language_preference_list)}) if statement_node.parent
      page.replace('context',
                   :partial => 'statements/context',
                   :locals => { :statement_node => statement_node.parent}) if statement_node.parent
      page.replace('discuss_sidebar',
                   :partial => 'statements/sidebar',
                   :locals => { :statement_node => statement_node.parent})
      # Direct JS
      page << "makeRatiobars();"
      page << "makeTooltips();"
    end
  end

  
  public
  # creates a new statement
  #
  # Method:   POST
  # Params:   statement: hash
  # Response: HTTP or JS
  #
  def create
    attrs = params[statement_class_param].merge({:creator_id => current_user.id})
    doc_attrs = attrs.delete(:statement_document)
    
    form_tags = attrs.delete(:tags)
    @statement_node ||= statement_node_class.new(attrs)
    @locale_language_id = locale_language_id
    @statement_document = @statement_node.add_statement_document(
                          doc_attrs.merge({:original_language_id => @locale_language_id}))
    @statement_node.add_tags(@tags, {:language_id => current_language_key}) unless @tags.nil?
    if @statement_node.taggable?
      @tags = @statement_node.update_tags(form_tags, @locale_language_id) 
      check_tag_permissions @statement_node
    end
    respond_to do |format|
      if @error.nil? and @statement_node.save
        @language_preference_list = language_preference_list
        set_statement_node_info("discuss.messages.created",@statement_node)
        current_user.supported!(@statement_node)
        #load current created statement_node to session
        load_to_session @statement_node if @statement_node.parent
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js   {
          @statement_node.visited_by!(current_user)
          @children = @statement_node.sorted_children(current_user,@language_preference_list).paginate(
                                                  StatementNode.default_scope.merge(:page => @page, :per_page => 5))
          render_create_statement_node(@statement_node,@statement_document,@children)
        }
      else
        @locale_language_id = locale_language_id
        set_error(@statement_document)
        @statement_node.tao_tags.each{|tao_tag|set_error(tao_tag)}
        format.html { flash_error and render :template => 'statements/new' }
        format.js   { show_error_messages }
      end
    end
  end
  
  private
  def render_create_statement_node(statement_node,statement_document,statement_node_children)
    render_with_info do |page|
      if statement_node.kind_of?(Question)
        page.redirect_to(url_for(statement_node))
      else
        page.replace('context',
                     :partial => 'statements/context',
                     :locals => { :statement_node => statement_node})
        page.replace('discuss_sidebar',
                     :partial => 'statements/sidebar',
                     :locals => { :statement_node => statement_node})
        page.replace('summary',
                     :partial => 'statements/summary',
                     :locals => { :statement_node => statement_node, :statement_document => statement_document})
        page.replace 'new_statement',
                   :partial => 'statements/children',
                   :statement => statement_node,
                   :children => statement_node_children
      end

      # Direct JS

      page << "makeRatiobars();"
      page << "makeTooltips();"
    end
  end
  public
  # renders a form to edit statements
  #
  # Method:   POST
  # Params:   id: integer 
  # Response: JS
  #
  def edit
    @statement_document ||= @statement_node.translated_document(language_preference_list)
    @locale_language_id = locale_language_id
    @tags = @statement_node.tags if @statement_node.taggable?
    respond_to do |format|
      format.html { render :template => 'statements/edit' }
      format.js { replace_container('summary', :partial => 'statements/edit') }
    end
  end

  # actually updates statements
  #
  # Method:   POST
  # Params:   statement: hash 
  # Response: JS
  #
  def update
    attrs = params[statement_class_param]
    @locale_language_id = locale_language_id
    attrs_doc = attrs.delete(:statement_document)
    # Updating tags of the statement
    form_tags = attrs.delete(:tags)
    if @statement_node.taggable?
      @tags = @statement_node.update_tags(form_tags, @locale_language_id) 
      check_tag_permissions(@statement_node)
    end
    respond_to do |format|
      if @error.nil? and
         @statement_node.update_attributes(attrs) and
         @statement_node.translated_document(language_preference_list).update_attributes(attrs_doc)
        set_statement_node_info("discuss.messages.updated",@statement_node)
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js   { show }
      else
        set_error(@statement_node)
        @statement_node.tao_tags.each{|tao_tag|set_error(tao_tag)}
        format.html { flash_error and redirect_to url_for(@statement_node) }
        format.js   { show_error_messages }
      end
    end
  end


  # destroys a statement_node
  #
  # Method:   DELETE
  # Params:   id: integer 
  # Response: HTTP
  #
  def destroy
    @statement_node.destroy
    set_statement_node_info("discuss.messages.deleted",@statement_node)
    flash_info and redirect_to :controller => 'questions', :action => :category, :id => params[:category]
  end

  # processes a cancel request, and redirects back to the last shown statement_node
  def cancel
    redirect_to url_f(StatementNode.find(session[:last_statement_node]))
  end

  #
  # PRIVATE
  #

  private
  def fetch_statement_node
    @statement_node ||= statement_node_class.find(params[:id]) if params[:id].try(:any?) && params[:id] =~ /\d+/
  end  

  def may_edit?
    current_user.may_edit? or @statement_node.translated_document(language_preference_list).author == current_user
  end

  def may_delete?
    current_user.may_delete?(@statement_node)
  end

  def statement_class_param
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  # returns the statement_node class, corresponding to the controllers name
  def statement_node_class
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end
  
  # Returns the parent statement node of the the current statement. Must be implemented by the subclasses.
  def parent
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  def set_statement_node_info(string, statement_node)
    set_info(string, :type => I18n.t("discuss.statements.types.#{statement_class_param.to_s}"))
  end  

  

  def set_tag_errors(statement_node)
    statement_node.tao_tags.each do |tao|
      index = tao.tag.value.index '#'
      if !index.nil? and index == 0 and !current_user.has_role? :topic_editor, tao.tag
        set_error('discuss.tag_permission', :tag => tao.tag.value)
      end
    end
  end
  
  ###############################
  #### TAGS
  ###############################

  def check_tag_permissions(statement_node)
    statement_node.tao_tags.each do |tao_tag|
      index = tao_tag.tag.value.index '#'
      if !index.nil? and index == 0 and !current_user.has_role? :topic_editor, tao_tag.tag
        set_error('discuss.tag_permission', :tag => tao_tag.tag.value)
      end
    end
  end
  
  def load_to_session(statement_node)
    type = statement_node_class.to_s.underscore
    key = ("current_" + type).to_sym
    session[key] = statement_node.parent.children.map{|s|s.id}
    session[:last_statement_node] = statement_node.id
  end

  def search (value, language_keys = language_preference_list, opts = {})
    StatementNode.search_statement_nodes("Question", value, language_keys, opts)
  end
end


