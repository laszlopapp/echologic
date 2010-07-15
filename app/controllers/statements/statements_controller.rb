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
  before_filter :fetch_statement_node, :except => [:category,:my_discussions,:new,:create]
  before_filter :require_user, :except => [:category, :show]
  before_filter :fetch_languages, :except => [:destroy]
  before_filter :require_decision_making_permission, :except => [:category,:show,:my_discussions]

  # authlogic access control block
  access_control do
    allow :editor
    allow anonymous, :to => [:index, :show, :category]
    allow logged_in
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

    statement_nodes_not_paginated = search_statement_nodes(:search_term => @value,
                                                           :language_ids => @language_preference_list,
                                                           :category => category,
                                                           :auth => current_user && current_user.has_role?(:editor))

    @count    = statement_nodes_not_paginated.size
    @statement_nodes = statement_nodes_not_paginated.paginate(:page => @page, :per_page => 6)
    @statement_documents = search_statement_documents(@statement_nodes.map { |s|
                                                        s.statement_id
                                                      }, @language_preference_list)

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
    @original_language_warning = @statement_node.not_original_language?(current_user, @locale_language_id)
    @translation_permission = @statement_node.translatable?(current_user,
                                                            @statement_document.language,
                                                            params[:locale],
                                                            @language_preference_list)

    # When creating an issue, we save the flash message within the session, to be able to display it here
    if session[:last_info]
      @info = session[:last_info]
      flash_info
      session[:last_info] = nil
    end

    # Find all child statement_nodes, which are published (except user is an editor)
    # sorted by supporters count, and paginate them
    @page = params[:page] || 1

    @children = @statement_node.sorted_children(current_user, @language_preference_list).
                  paginate(StatementNode.default_scope.merge(:page => @page, :per_page => 5))
    @children_documents = search_statement_documents(@children.map { |s| s.statement_id }, @language_preference_list)

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
    @statement_node.add_subscriber(current_user)
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
    @statement_node.remove_subscriber(current_user)
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
    @new_statement_document ||= @statement_node.add_statement_document({:language_id => @locale_language_id})
    respond_to do |format|
      format.html { render :template => 'statements/translate' }
      format.js {render :partial => 'statements/new_translation.rjs'}
    end
  end

  # Creates a translation of a statement according to the fields from a form that was submitted
  #
  # Method:   POST
  # Params:   new_statement_document: hash
  # Response: JS
  #
  def create_translation
    attrs = params[statement_node_symbol]
    doc_attrs = attrs.delete(:new_statement_document).merge({:author_id => current_user.id,
                                                             :language_id => @locale_language_id})
    @new_statement_document = @statement_node.add_statement_document(doc_attrs)
    respond_to do |format|
      if @statement_node.save
        set_statement_node_info("discuss.messages.translated",@statement_node)
        @statement_document = @new_statement_document
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js {render :partial => 'statements/create.rjs'}
      else
        @statement_document = StatementDocument.find(doc_attrs[:translated_document_id])
        set_error(@new_statement_document)
        format.html { flash_error and render :template => 'statements/translate' }
        format.js { show_error_messages(@new_statement_document) }
      end
    end
  end

  # Renders form for creating a new statement.
  #
  # Method:   GET
  # Params:   parent_id: integer, root_id: integer
  # Response: JS
  #
  def new
    @statement_node ||= statement_node_class.new(:parent => parent, :root_id => root_symbol)
    @statement_document ||= StatementDocument.new

    @tags = @statement_node.tags if @statement_node.taggable?
    # TODO: right now users can't select the language they create a statement in, so current_user.languages_keys.
    # first will work. once this changes, we're in trouble - or better said: we'll have to pass the language_id as a param
    respond_to do |format|
      format.html { render :template => 'statements/new' }
      format.js {render :partial => 'statements/new.rjs'}
    end
  end
  # creates a new statement
  #
  # Method:   POST
  # Params:   statement: hash
  # Response: HTTP or JS
  #
  def create
    attrs = params[statement_node_symbol].merge({:creator_id => current_user.id})
    doc_attrs = attrs.delete(:statement_document)

    form_tags = attrs.delete(:tags)
    @statement_node ||= statement_node_class.new(attrs)
    @statement_document = @statement_node.add_statement_document(
                          doc_attrs.merge({:original_language_id => @locale_language_id}))
    if @statement_node.taggable?
      @tags = @statement_node.update_tags(form_tags, @locale_language_id)
      check_tag_permissions @statement_node
    end
    respond_to do |format|
      if @error.nil? and @statement_node.save
        set_statement_node_info("discuss.messages.created",@statement_node)
        current_user.supported!(@statement_node)
        #load current created statement_node to session
        load_to_session @statement_node if @statement_node.parent
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js {
          @statement_node.visited_by!(current_user)
          @children = [].paginate(StatementNode.default_scope.merge(:page => @page,
                                                                    :per_page => 5))
          render :partial => 'statements/create.rjs'
        }
      else
        set_error(@statement_document)
        @statement_node.tao_tags.each{|tao_tag|set_error(tao_tag)}
        format.html { flash_error and render :template => 'statements/new' }
        format.js   { show_error_messages }
      end
    end
  end

  # renders a form to edit statements
  #
  # Method:   POST
  # Params:   id: integer
  # Response: JS
  #
  def edit
    @statement_document ||= @statement_node.translated_document(@language_preference_list)
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
    attrs = params[statement_node_symbol]
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
         @statement_node.translated_document(@language_preference_list).update_attributes(attrs_doc)
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


  # Destroys a statement_node.
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

  # Gets the correspondent statement node to the id that is given in the request
  private
  def fetch_statement_node
    @statement_node ||= statement_node_class.find(params[:id]) if params[:id].try(:any?) && params[:id] =~ /\d+/
  end

  # loads the locale language and the language preference list
  def fetch_languages
    @locale_language_id = locale_language_id
    @language_preference_list = language_preference_list
  end

  # returns the statement node correspondent symbol (:question, :proposal...). Must be implemented by the subclasses.
  def statement_node_symbol
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  # returns the statement_node class, corresponding to the controllers name. Must be implemented by the subclasses.
  def statement_node_class
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  # Returns the parent statement node of the current statement. Must be implemented by the subclasses.
  def parent
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  def set_statement_node_info(string, statement_node)
    set_info(string, :type => I18n.t("discuss.statements.types.#{statement_node_symbol.to_s}"))
  end

  # Checks if the statement node or parent has a * tag and the user has permission for it
  def require_decision_making_permission
    user_decision_making_tags = current_user.concernments.in_context(
                                TaoTag.tag_contexts("decision_making")).map{|c|c.tag.value}
    statement = @statement_node || parent
    return true if statement.nil?
    tags = statement.root.tao_tags.map{|t|t.tag.value}
    tags.each do |tag|
      index = tag.index '*'
      if !index.nil? and index == 0
        if !user_decision_making_tags.include? tag
          set_info('discuss.statements.error_messages.no_decision_making_permission',
                   :tag => tag[1,tag.length-1])
          respond_to do |format|
            format.html { flash_info and redirect_to(url_for(statement)) }
            format.js do
              render_with_info
            end
          end
          return false
        end
      end
    end
    return true
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

  # Calls the statement node sql query for questions.
  def search_statement_nodes (opts = {})
    StatementNode.search_statement_nodes(opts.merge({:type => "Question"}))
  end

  # Gets all the statement documents belonging to a group of statements, and orders them per language ids.
  def search_statement_documents (statement_ids, language_ids = @language_preference_list)
    hash = {}
    statement_documents = StatementDocument.search_statement_documents(statement_ids, language_ids)
    statement_documents = statement_documents.sort do |a, b|
      language_ids.index(a.language_id) <=> language_ids.index(b.language_id)
    end
    statement_documents.each do |sd|
      hash.store(sd.statement_id, sd) unless hash.has_key?(sd.statement_id)
    end
    hash
  end
end


