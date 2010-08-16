class StatementsController < ApplicationController
  @@edit_locking_time = 1.hours
  helper :echo
  include EchoHelper
  include StatementHelper


  # Remodelling the RESTful constraints, as a default route is currently active
  # FIXME: the echo and unecho actions should be accessible via PUT/DELETE only,
  #        but that is currently undoable without breaking non-js requests. A
  #        solution would be to make the "echo" button a real submit button and
  #        wrap a form around it.
  verify :method => :get, :only => [:index, :show, :new, :edit, :category, :new_translation]
  verify :method => :post, :only => [:create]
  verify :method => :put, :only => [:update, :create_translation, :publish]
  verify :method => :delete, :only => [:destroy]

  # The order of these filters matters. change with caution.
  before_filter :fetch_statement_node, :except => [:category, :my_discussions, :new, :create]
  before_filter :require_user, :except => [:category, :show]
  before_filter :fetch_languages, :except => [:destroy]
  before_filter :require_decision_making_permission, :only => [:echo, :unecho, :new, :new_translation]
  before_filter :check_empty_text, :only => [:create, :update, :create_translation]

  # Authlogic access control block
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
                                                           :show_unpublished => current_user &&
                                                                                current_user.has_role?(:editor))

    @count    = statement_nodes_not_paginated.size
    @statement_nodes = statement_nodes_not_paginated.paginate(:page => @page,
                                                              :per_page => 6)
    @statement_documents = search_statement_documents(@statement_nodes.map { |s|
                                                        s.statement_id
                                                      }, @language_preference_list)

    respond_to_js :template => 'statements/questions/index',
                  :template_js => 'statements/questions/questions'
  end


  # Shows a selected statement
  #
  # Method:   GET
  # Params:   id: integer
  # Response: HTTP or JS
  #
  def show
    # Record visited
    @statement_node.visited!(current_user) if current_user

    # Store last statement in session (for cancel link)
    session[:last_statement_node] = @statement_node.id

    # Prev / Next functionality
    unless @statement_node.children.empty?
      child_type = ("current_" + @statement_node.class.expected_children.first.to_s.underscore).to_sym
      session[child_type] = @statement_node.children_statements(@language_preference_list).collect { |c| c.id }
    end

    # Get document to show and redirect if not found
    @statement_document = @statement_node.translated_document(@language_preference_list)
    if @statement_document.nil?
      redirect_to(discuss_search_path)
      return
    end

    # Test for special links
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

    # If statement node is draftable, then try to get the approved one
    if @statement_node.draftable?
      @approved_node = @statement_node.approved_children.first || nil
      @approved_document = @approved_node.translated_document(@language_preference_list) if !@approved_node.nil?
    end

    # Find all child statement_nodes, which are published (except user is an editor)
    # sorted by supporters count, and paginate them
    @page = params[:page] || 1

    @children = @statement_node.children_statements(@language_preference_list).
                  paginate(StatementNode.default_scope.merge(:page => @page,
                                                             :per_page => 5))
    @children_documents = search_statement_documents(@children.map { |s| s.statement_id },
                                                     @language_preference_list)

    respond_to do |format|
      format.html {render :template => 'statements/show' } # show.html.erb
      format.js   {render :template => 'statements/show' } # show.js.erb
    end
  end


  #
  # Renders form for creating a new statement.
  #
  # Method:   GET
  # Params:   parent_id: integer, root_id: integer
  # Response: JS
  #
  def new
    @statement_node ||= statement_node_class.new(:parent => parent,
                                                 :root_id => root_symbol)
    @statement_document ||= StatementDocument.new
    @action ||= StatementHistory.statement_actions("created")
    @statement_node.topic_tags << "##{params[:category]}" if params[:category]
    @tags ||= @statement_node.topic_tags if @statement_node.taggable?
    # TODO: right now users can't select the language they create a statement in, so current_user.languages_keys.
    # first will work. once this changes, we're in trouble - or better said: we'll have to pass the language_id as a param

    respond_to_js :template => 'statements/new',
                  :partial_js => 'statements/new.rjs'
  end


  #
  # Creates a new statement.
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
                          doc_attrs.merge({:original_language_id => @locale_language_id,
                                           :current => true}))
    permitted = true ; @tags = []
    if @statement_node.taggable? and (permitted = check_hash_tag_permissions(form_tags))
      @statement_node.topic_tags=form_tags
      @tags=@statement_node.topic_tags
    end

    respond_to do |format|
      if permitted and @statement_node.save
        set_statement_node_info(@statement_document)
        #load current created statement_node to session
        load_to_session @statement_node if @statement_node.parent
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js {
          @statement_node.visited!(current_user)
          @children = [].paginate(StatementNode.default_scope.merge(:page => @page,
                                                                    :per_page => 5))
          render :partial => 'statements/create.rjs'
        }
      else
        set_error(@statement_document)
        format.html { flash_error and render :template => 'statements/new' }
        format.js   { show_error_messages }
      end
    end
  end


  #
  # Renders a form to edit statements
  #
  # Method:   POST
  # Params:   id: integer
  # Response: JS
  #
  def edit
    @statement_document ||= @statement_node.translated_document(@language_preference_list)
    has_lock = acquire_lock(@statement_document)
    @tags ||= @statement_node.topic_tags if @statement_node.taggable?
    @action ||= StatementHistory.statement_actions("updated")
    if has_lock
      respond_to_js :template => 'statements/edit',
                    :partial_js => 'statements/edit.rjs'
    else
      respond_to do |format|
        set_info('discuss.statements.being_edited')
        format.html { flash_info and render :template => 'statements/edit' }
        format.js   { render_with_info }
      end
    end
  end


  #
  # Updates statements
  #
  # Method:   POST
  # Params:   statement: hash
  # Response: JS
  #
  def update
    attrs = params[statement_node_symbol]
    attrs_doc = attrs.delete(:statement_document)
    locked_at = attrs_doc.delete(:locked_at)

    # Updating tags of the statement
    form_tags = attrs.delete(:tags)
    has_tag_permissions = !@statement_node.taggable? || check_hash_tag_permissions(form_tags)

    holds_lock = ok = true
    saved = false
    if has_tag_permissions
      begin
        StatementNode.transaction do
          old_statement_document = StatementDocument.find(attrs_doc[:old_document_id])
          holds_lock = holds_lock?(old_statement_document, locked_at)
          if (holds_lock)
            old_statement_document.update_attribute(:current, false)
            old_statement_document.save!
            @statement_document = @statement_node.add_statement_document(
                                    attrs_doc.merge({:original_language_id => @locale_language_id,
                                                     :current => true}))
            @statement_document.save!

            if @statement_node.taggable?
              @statement_node.topic_tags=form_tags
              @tags=@statement_node.topic_tags
            end
            @statement_node.save!
          end
        end
      rescue StandardError => error
        log_error(error)
        ok = false
      else
        logger.info("Statement has been updated sucessfully.")
      end
    end

    respond_to do |format|
      if !holds_lock
          set_error('discuss.statements.staled_modification')
          format.html { flash_error and redirect_to url_for(@statement_node) }
          format.js { show }
      elsif !has_tag_permissions || !ok
        set_error(@statement_document) if @statement_document
        set_error(@statement_node)
        format.html { flash_error and redirect_to url_for(@statement_node) }
        format.js   { show_error_messages }
      else
        set_statement_node_info(@statement_document)
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js   { show }
      end
    end
  end


  ################
  # TRANSLATIONS #
  ################

  #
  # Renders the new statement translation form when called
  #
  # Method:   GET
  # Response: JS
  #
  def new_translation
    @statement_document ||= @statement_node.translated_document(current_user.sorted_spoken_language_ids)
    @new_statement_document ||= @statement_node.add_statement_document({:language_id => @locale_language_id})
    @action ||= StatementHistory.statement_actions("translated")
    respond_to_js :template => 'statements/translate',
                  :partial_js => 'statements/new_translation.rjs'
  end

  #
  # Creates a translation of a statement according to the fields from a form that was submitted
  #
  # Method:   POST
  # Params:   new_statement_document: hash
  # Response: JS
  #
  def create_translation
    attrs = params[statement_node_symbol]
    doc_attrs = attrs.delete(:new_statement_document).merge({:author_id => current_user.id,
                                                             :language_id => @locale_language_id,
                                                             :current => true})
    @new_statement_document = @statement_node.add_statement_document(doc_attrs)
    respond_to do |format|
      if @statement_node.save
        @statement_document = @new_statement_document
        set_statement_node_info(@statement_document)
        format.html { flash_info and redirect_to url_for(@statement_node) }
        format.js {render :partial => 'statements/create_translation.rjs'}
      else
        @statement_document = StatementDocument.find(doc_attrs[:old_document_id])
        set_error(@new_statement_document)
        format.html { flash_error and render :template => 'statements/translate' }
        format.js { show_error_messages(@new_statement_document) }
      end
    end
  end

  #
  # Processes a cancel request, and redirects back to the last shown statement_node
  #
  def cancel
    locked_at = params[:locked_at]
    statement_document = @statement_node.translated_document(@language_preference_list)
    if holds_lock?(statement_document, locked_at)
      statement_document.unlock
    end
    respond_to do |format|
      format.html { redirect_to url_for(@statement_node)}
      format.js   { show }
    end
  end


  ###################
  # ECHO STATEMENTS #
  ###################

  #
  # Called if user supports this statement_node. Updates the support field in the corresponding
  # echo object.
  #
  # Method:   POST
  # Response: JS
  #
  def echo
    return if !@statement_node.echoable?
    if !@statement_node.parent.echoable? or @statement_node.parent.supported?(current_user)
      @statement_node.supported!(current_user)
      respond_to_js :redirect_to => @statement_node, :template_js => 'statements/echo'
    else
      respond_to do |format|
        set_error('discuss.statements.unsupported_parent')
        format.html { redirect_to url_for(@statement_node) }
        format.js { show_error_messages }
      end
    end
  end

  #
  # Called if user doesn't support this statement_node any longer. Sets the supported field
  # of the corresponding echo object to false.
  #
  # Method:   POST
  # Response: HTTP or JS
  #
  def unecho
    return if !@statement_node.echoable?

    @statement_node.unsupported!(current_user)
    @statement_node.children.each{|c|c.unsupported!(current_user) if c.supported?(current_user)}

    # Logic to update the children caused by cascading unsupport
    @page = params[:page] || 1
    @children = @statement_node.children_statements(@language_preference_list).
                  paginate(StatementNode.default_scope.merge(:page => @page, :per_page => 5))
    @children_documents = search_statement_documents(@children.map { |s| s.statement_id },
                                                     @language_preference_list)
    respond_to_js :redirect_to => @statement_node,
                  :template_js => 'statements/unecho'
  end


  #################
  # ADMIN ACTIONS #
  #################

  #
  # Destroys a statement_node.
  #
  # Method:   DELETE
  # Params:   id: integer
  # Response: HTTP
  #
  def destroy
    @statement_node.destroy
    set_statement_node_info(nil, "discuss.messages.deleted")
    flash_info and redirect_to :controller => 'questions',
                               :action => :category,
                               :id => params[:category]
  end


  #############
  # PROTECTED #
  #############

  protected

  #
  # Returns true if the current user could successfully acquire the lock.
  #
  def acquire_lock(statement_document)
    StatementDocument.transaction do
      if statement_document.locked_by.nil?
        statement_document.lock(current_user)
      elsif current_user != statement_document.locked_by
        if statement_document.locked_at >= @@edit_locking_time.ago
          return false
        else
          statement_document.lock(current_user)
        end
      end
    end
    return true
  end

  #
  # Returns true if the current user still holds his original lock he acquired when starting to edit the statement.
  #
  def holds_lock?(statement_document, locked_at)
    statement_document.locked_by == current_user && statement_document.locked_at.to_s == locked_at
  end


  ###########
  # PRIVATE #
  ###########

  private

  # Gets the correspondent statement node to the id that is given in the request
  def fetch_statement_node
    @statement_node ||= statement_node_class.find(params[:id]) if params[:id].try(:any?) && params[:id] =~ /\d+/
  end

  # Loads the locale language and the language preference list
  def fetch_languages
    @locale_language_id = locale_language_id
    @language_preference_list = language_preference_list
  end

  # Checks if text that comes with the form is actually empty, even with the escape parameters from the iframe
  def check_empty_text
    document_param = params[statement_node_symbol][:new_statement_document] || params[statement_node_symbol][:statement_document]
    text = document_param[:text]
    document_param[:text] = "" if text.eql?('<br>')
  end

  # Returns the statement node correspondent symbol (:question, :proposal...). Must be implemented by the subclasses.
  def statement_node_symbol
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  # Returns the statement_node class, corresponding to the controllers name. Must be implemented by the subclasses.
  def statement_node_class
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  # Returns the parent statement node of the current statement. Must be implemented by the subclasses.
  def parent
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  # Sets the info to displayed along with the response.
  # The action name is automagically incorporated into the I18n key.
  #
  def set_statement_node_info(statement_document, string=nil)
    set_info((string || "discuss.messages.#{statement_document.action.code}"),
             :type => I18n.t("discuss.statements.types.#{statement_node_symbol.to_s}"))
  end


  ###############
  # PERMISSIONS #
  ###############

  # Checks if the statement node or parent has a * tag and the user has permission for it
  def require_decision_making_permission
    decision_making_tags = current_user.decision_making_tags
    statement = @statement_node || parent
    return true if statement.nil?
    tags = statement.root.tags.map{|t|t.value}
    tags.each do |tag|
      index = tag.index '*'
      next if index != 0
      if !decision_making_tags.include? tag
        set_info('discuss.statements.read_only_permission')
        respond_to do |format|
          format.html { flash_info and redirect_to(url_for(statement)) }
          format.js do
            render_with_info
          end
        end
        return false
      end
    end
    return true
  end


  # Checks whether the user is allowed to assign the given hash tags (#tag)
  def check_hash_tag_permissions(tags_values)

    # Editors can define all tags
    return true if current_user.has_role? :editor

    # Check the individual hash tag permissions
    decision_making_tags = current_user.decision_making_tags
    tags = tags_values.split(',').map{|t|t.strip}.uniq
    tags.each do |tag|
      index = tag.index '#'
      next if index != 0
      decision_making_tag = '*' + tag[1..-1]
      if !current_user.is_topic_editor(tag) and
         !decision_making_tags.include? decision_making_tag
        set_error('discuss.tag_permission', :tag => tag)
      end
    end
    @error.nil? ? true : false
  end


  ##########
  # SEARCH #
  ##########

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


  ########
  # MISC #
  ########

  # Saves the current statement node to the session to enable back navigation
  def load_to_session(statement_node)
    type = statement_node_class.to_s.underscore
    key = ("current_" + type).to_sym
    session[key] = statement_node.parent.children_statements(@language_preference_list).map{|s|s.id}
    session[:last_statement_node] = statement_node.id
  end

end


