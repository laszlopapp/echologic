class StatementsController < ApplicationController
  helper :echo
  include EchoHelper
  include StatementsHelper

  # Remodelling the RESTful constraints, as a default route is currently active
  # FIXME: the echo and unecho actions should be accessible via PUT/DELETE only,
  #        but that is currently undoable without breaking non-js requests. A
  #        solution would be to make the "echo" button a real submit button and
  #        wrap a form around it.

  verify :method => :get, :only => [:index, :show, :new, :edit, :category, :new_translation,
                                    :children, :upload_image, :reload_image]
  verify :method => :post, :only => [:create]
  verify :method => :put, :only => [:update, :create_translation, :publish]
  verify :method => :delete, :only => [:destroy]

  # The order of these filters matters. change with caution.
  before_filter :fetch_statement_node, :except => [:category, :my_discussions, :new, :create]
  before_filter :redirect_if_approved_or_incorporated, :except => [:category, :my_discussions,
                                                                   :new, :create, :children, :upload_image,
                                                                   :reload_image]
  before_filter :require_user, :except => [:category, :show, :children]
  before_filter :fetch_languages, :except => [:destroy]
  before_filter :require_decision_making_permission, :only => [:echo, :unecho, :new, :new_translation]
  before_filter :check_empty_text, :only => [:create, :update, :create_translation]

  # Authlogic access control block
  access_control do
    allow :editor
    allow anonymous, :to => [:index, :show, :category, :children]
    allow logged_in
  end


  ##############
  # ATTRIBUTES #
  ##############

  @@edit_locking_time = 1.hours


  ###########
  # ACTIONS #
  ###########

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

    # PREV / NEXT functionality for questions
    session[:current_question] = statement_nodes_not_paginated.map(&:id)

    @count    = statement_nodes_not_paginated.size
    @statement_nodes = statement_nodes_not_paginated.paginate(:page => @page,
                                                              :per_page => 6)
    @statement_documents = search_statement_documents(@statement_nodes.map(&:statement_id), @language_preference_list)

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

    begin
      # Record visited
      @statement_node.visited!(current_user) if current_user


      # Load statement node data to session for prev/next functionality
      load_to_session(@statement_node)

      # Get document to show and redirect if not found
      @statement_document = @statement_node.document_in_preferred_language(@language_preference_list)
      if @statement_document.nil?
        redirect_to(discuss_search_path)
        return
      end

      # Test for special links
      @original_language_warning = @statement_node.not_original_language?(current_user, @locale_language_id)
      @translation_permission = @statement_node.original_language == @statement_document.language &&
                                @statement_node.translatable?(current_user,
                                                              @statement_document.language,
                                                              Language[params[:locale]])

      # When creating an issue, we save the flash message within the session, to be able to display it here
      if session[:last_info]
        @info = session[:last_info]
        flash_info
        session[:last_info] = nil
      end

      # If statement node is draftable, then try to get the approved one
      load_approved_statement

      # Find all child statement_nodes, which are published (except user is an editor)
      # sorted by supporters count, and paginate them
      @page = params[:page] || 1
      @per_page = INITIAL_CHILDREN
      @offset = 0
      @children = @statement_node.children_statements(@language_preference_list).
                    paginate(StatementNode.default_scope.merge(:page => @page,
                                                               :per_page => @per_page))
      @children_documents = search_statement_documents(@children.map { |s| s.statement_id },
                                                       @language_preference_list)

      respond_to_js :template => 'statements/show',
                    :partial_js => 'statements/show.rjs'

rescue Exception => e
      log_home_error(e,"Error showing statement.")
    end
  end


  def children
    @page = params[:page] || 1
    @per_page = 7
    @offset = @page.to_i == 1 ? 3 : 0
    @children = @statement_node.children_statements(@language_preference_list).
                  paginate(StatementNode.default_scope.merge(:page => @page,
                                                             :per_page => @per_page))
    @children_documents = search_statement_documents(@children.map { |s| s.statement_id },
                                                     @language_preference_list)
    respond_to_js :partial_js => 'statements/children.rjs'
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
                                                 :root_id => root_symbol,
                                                 :editorial_state => StatementState[:new])
    @statement_document ||= StatementDocument.new(:language_id => @locale_language_id)
    @action ||= StatementAction["created"]
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

    begin
      @statement_node ||= statement_node_class.new(attrs)
      @statement_node.statement ||= Statement.new
      @statement_document = @statement_node.add_statement_document(
                            doc_attrs.merge({:original_language_id => doc_attrs[:language_id],
                                             :current => true}))
      permitted = true ; @tags = []
      if @statement_node.taggable? and (permitted = check_hash_tag_permissions(form_tags))
        @statement_node.topic_tags=form_tags
        @tags=@statement_node.topic_tags
      end

      respond_to do |format|
        if permitted and @statement_node.save
          EchoService.instance.created(@statement_node)
          set_statement_node_info(@statement_document)
          # load currently created statement_node to session
          load_to_session @statement_node
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
    rescue Exception => e
      log_message_error(e, "Error creating statement node.") do |format|
        format.html { flash_error and render :template => 'statements/new' }
      end
    else
      log_message_info("Statement node has been created sucessfully.") if @statement_node
    end
  end


  #
  # Renders a form to edit the current statement.
  #
  # Method:   POST
  # Params:   id: integer
  # Response: JS
  #
  def edit
    @statement_document ||= @statement_node.document_in_preferred_language(@language_preference_list)
    if (is_current_document = (@statement_document.id == params[:current_document_id].to_i))
      has_lock = acquire_lock(@statement_document)
      @tags ||= @statement_node.topic_tags if @statement_node.taggable?
      @action ||= StatementAction["updated"]
    end

    if !is_current_document
      with_info(:template => 'statements/edit' ) do |format|
        set_statement_node_info(nil, 'discuss.statements.statement_updated')
      end
    elsif has_lock
      respond_to_js :template => 'statements/edit',
                    :partial_js => 'statements/edit.rjs'
    else
      with_info(:template => 'statements/edit' ) do |format|
        set_info('discuss.statements.being_edited')
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
    update = update_image = false
    begin
      attrs = params[statement_node_symbol]
      attrs_doc = attrs.delete(:statement_document)
      locked_at = attrs_doc.delete(:locked_at) if attrs_doc

      # Updating tags of the statement
      form_tags = attrs.delete(:tags)
      has_tag_permissions = form_tags.nil? || !@statement_node.taggable? || check_hash_tag_permissions(form_tags)

      holds_lock = true
      if has_tag_permissions
        StatementNode.transaction do
          if attrs_doc # normal edit or incorporate form
            old_statement_document = StatementDocument.find(attrs_doc[:old_document_id])
            holds_lock = holds_lock?(old_statement_document, locked_at)
            if (holds_lock)
              old_statement_document.update_attribute(:current, false)
              old_statement_document.save!
              @statement_document = @statement_node.add_statement_document(
                                      attrs_doc.merge({:original_language_id => @locale_language_id,
                                                       :current => true}))
              @statement_document.save

              if @statement_node.taggable? and form_tags
                @statement_node.topic_tags=form_tags
                @tags=@statement_node.topic_tags
              end
              @statement_node.save
            end
          else #update image
            @statement_node.update_attributes(attrs)
            @statement_node.statement_image.save
            update_image = true
          end
        end
      end

      if attrs_doc #normal form POST
        respond_to do |format|
          if !holds_lock
              being_edited(format)
          elsif has_tag_permissions and @statement_node.valid? and @statement_document.valid?
            update = true
            set_statement_node_info(@statement_document)
            format.html { flash_info and redirect_to url_for(@statement_node) }
            format.js   { show }
          else
            set_error(@statement_document) if @statement_document
            set_error(@statement_node)
            format.html { flash_error and redirect_to url_for(@statement_node) }
            format.js   { show_error_messages }
          end
        end
      else
        respond_to do |format|
          format.html {redirect_to url_for(@statement_node)}
          format.js {show}
        end
      end
    rescue Exception => e
      log_statement_error(e, "Error updating statement node '#{@statement_node.id}'.")
    else
      log_message_info("Statement node '#{@statement_node.id}' has been updated sucessfully.") if update
      log_message_info("Statement node '#{@statement_node.id}' has a new image.") if update_image
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
    @statement_document ||= @statement_node.document_in_preferred_language(@language_preference_list)
    if (is_current_document = @statement_document.id == params[:current_document_id].to_i) and
       !(already_translated = @statement_document.language_id == @locale_language_id)
      has_lock = acquire_lock(@statement_document)
      @new_statement_document ||= @statement_node.add_statement_document({:language_id => @locale_language_id})
      @action ||= StatementAction["translated"]
    end
    if !is_current_document
      with_info(:template => 'statements/new_translation' ) do |format|
        set_statement_node_info(nil,'discuss.statements.statement_updated')
      end
    elsif already_translated
      with_info(:template => 'statements/new_translation' ) do |format|
        set_statement_node_info(nil,'discuss.statements.already_translated')
      end
    elsif has_lock
      respond_to_js :template => 'statements/translate',
                    :partial_js => 'statements/new_translation.rjs'
    else
      with_info(:template => 'statements/new_translation' ) do |format|
        set_info('discuss.statements.being_edited')
      end
    end
  end

  #
  # Creates a translation of a statement according to the fields from a form that was submitted
  #
  # Method:   POST
  # Params:   new_statement_document: hash
  # Response: JS
  #
  def create_translation
    translated = false
    begin
      attrs = params[statement_node_symbol]
      new_doc_attrs = attrs.delete(:new_statement_document).merge({:author_id => current_user.id,
                                                                   :language_id => @locale_language_id,
                                                                   :current => true})
      locked_at = new_doc_attrs.delete(:locked_at)

      # Updating the statement
      holds_lock = true

      StatementNode.transaction do
        old_statement_document = StatementDocument.find(new_doc_attrs[:old_document_id])
        holds_lock = holds_lock?(old_statement_document, locked_at)
        if (holds_lock)
          @new_statement_document = @statement_node.add_statement_document(new_doc_attrs)
          @new_statement_document.save
          @statement_node.save
        end
      end

      # Rendering response
      respond_to do |format|
        if !holds_lock
          being_edited(format)
        elsif @new_statement_document.valid?
          translated = true
          @statement_document = @new_statement_document
          set_statement_node_info(@statement_document)
          format.html { flash_info and redirect_to url_for(@statement_node) }
          format.js {render :partial => 'statements/create_translation.rjs'}
        else
          @statement_document = StatementDocument.find(new_doc_attrs[:old_document_id])
          set_error(@new_statement_document)
          format.html { flash_error and render :template => 'statements/translate' }
          format.js { show_error_messages(@new_statement_document) }
        end
      end
    rescue Exception => e
      log_message_error(e, "Error translating statement node '#{@statement_node.id}'.") do |format|
        format.html { flash_error and render :template => 'statements/translate' }
      end
    else
      log_message_info("Statement node '#{@statement_node.id}' has been translated sucessfully.") if translated
    end
  end

  #
  # Processes a cancel request, and redirects back to the last shown statement_node
  #
  def cancel
    locked_at = params[:locked_at]
    statement_document = @statement_node.document_in_preferred_language(@language_preference_list)
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
    begin
      return if !@statement_node.echoable?
      if !@statement_node.parent.echoable? or @statement_node.parent.supported?(current_user)
        @statement_node.supported!(current_user)
        respond_to_js :redirect_to => @statement_node, :template_js => 'statements/echo'
      else
        respond_to do |format|
          set_info('discuss.statements.unsupported_parent')
          format.html { flash_info and redirect_to url_for(@statement_node) }
          format.js { render_with_info }
        end
      end
    rescue Exception => e
      log_statement_error(e, "Error echoing statement node '#{@statement_node.id}'.")
    else
      log_message_info("Statement node '#{@statement_node.id}' has been echoed sucessfully.")
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
    begin
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
    rescue Exception => e
      log_statement_error(e, "Error unechoing statement node '#{@statement_node.id}'.")
    else
      log_message_info("Statement node '#{@statement_node.id}' has been unechoed sucessfully.")
    end
  end

  #
  # Loads the form to insert an image in the current statement.
  #
  # Method:   GET
  # Response: JS
  #
  # Calls a js template which opens the upload picture dialog.
  def upload_image
    respond_to_js :template_js => 'statements/upload_image'
  end

  # After uploading the image, this has to be reloaded.
  # Reloading:
  #  1. loginContainer with users picture as profile link
  #  2. picture container of the profile
  #
  # Method:   GET
  # Response: JS
  #
  def reload_image
    respond_to do |format|
      if @statement_node.image.exists? and @statement_node.image.updated_at != params[:date].to_i
        set_statement_node_info(nil, 'discuss.messages.image_uploaded')
        format.js {
          render_with_info do |page|
            page.replace 'statement_image', :partial => 'statements/image'
            page.remove 'upload_image_link' if @statement_node.published?
          end
        }
      else
        set_error('discuss.statements.upload_image.error')
        format.js   { show_error_messages }
      end
    end
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
    begin
      @statement_node.destroy
      set_statement_node_info(nil, "discuss.messages.deleted")
      flash_info and redirect_to :controller => 'questions',
                                 :action => :category,
                                 :id => params[:category]
    rescue Exception => e
      log_message_error(e, "Error deleting statement node '#{@statement_node.id}'.") do |format|
        format.html { flash_error and redirect_to url_for(@statement_node) }
      end
    else
      log_message_info("Statement node '#{@statement_node.id}' has been deleted sucessfully.")
    end
  end



  #############
  # PROTECTED #
  #############

  protected

  #
  # Loads the approved statement if there can be any.
  #
  def load_approved_statement
    if @statement_node.draftable?
      @approved_node = @statement_node.approved_children.first || nil
      @approved_document = @approved_node.document_in_preferred_language(@language_preference_list) if !@approved_node.nil?
    end
  end

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

  #
  # Gets the correspondent statement node to the id that is given in the request
  #
  def fetch_statement_node
    @statement_node ||= statement_node_class.find(params[:id]) if params[:id].try(:any?) && params[:id] =~ /\d+/
  end

  #
  # Redirect to parent if incorporable is approved or already incorporated.
  #
  def redirect_if_approved_or_incorporated
    begin
      if @statement_node.incorporable? && (@statement_node.approved? || @statement_node.incorporated?)
        if @statement_node.approved?
          set_info("discuss.statements.see_parent_if_approved")
        else
          set_info("discuss.statements.see_parent_if_incorporated")
        end
        respond_to do |format|
          flash_info
          format.html { redirect_to @statement_node.parent }
          format.js do
            render :update do |page|
              page.redirect_to @statement_node.parent
            end
          end
        end
        return
      end
    rescue Exception => e
      log_home_error(e,"Error running redirect approved/incorporated IP filter")
    end
  end

  #
  # Loads the locale language and the language preference list
  #
  def fetch_languages
    @locale_language_id = locale_language_id
    @language_preference_list = language_preference_list
  end

  #
  # Checks if text that comes with the form is actually empty, even with the escape parameters from the iframe
  #
  def check_empty_text
    if params[statement_node_symbol].include? :new_statement_document or
       params[statement_node_symbol].include? :statement_document
      document_param = params[statement_node_symbol][:new_statement_document] || params[statement_node_symbol][:statement_document]
      text = document_param[:text]
      document_param[:text] = "" if text.eql?('<br>')
    end
  end

  #
  # Returns the statement node correspondent symbol (:question, :proposal...). Must be implemented by the subclasses.
  #
  def statement_node_symbol
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  #
  # Returns the statement_node class, corresponding to the controllers name. Must be implemented by the subclasses.
  #
  def statement_node_class
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  #
  # Returns the parent statement node of the current statement. Must be implemented by the subclasses.
  #
  def parent
    raise NotImplementedError.new("This method must be implemented by subclasses.")
  end

  #
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

  #
  # Checks if the statement node or parent has a * tag and the user has permission for it.
  #
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

  #
  # Checks whether the user is allowed to assign the given hash tags (#tag).
  #
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

  #
  # Calls the statement node sql query for questions.
  #
  def search_statement_nodes (opts = {})
    StatementNode.search_statement_nodes(opts.merge({:type => "Question"}))
  end

  #
  # Gets all the statement documents belonging to a group of statements, and orders them per language ids.
  #
  def search_statement_documents (statement_ids, language_ids = @language_preference_list)
    statement_documents = StatementDocument.search_statement_documents(statement_ids, language_ids).sort! {|a, b|
      language_ids.index(a.language_id) <=> language_ids.index(b.language_id)
    }
    statement_documents.each_with_object({}) do |sd, documents_hash|
      documents_hash[sd.statement_id] = sd unless documents_hash.has_key?(sd.statement_id)
    end
  end


  ########
  # MISC #
  ########

  #
  # Saves the current statement node to the session to enable back navigation
  #
  def load_to_session(statement_node, reload = true)

    # Load parent information to session
    load_to_session(statement_node.parent, false) if statement_node.parent

    # Loads sibling (or other question) statements to session if they were not loaded yet
    key = ("current_" + statement_node_class.to_s.underscore).to_sym
    if session[key].nil? or (reload and !statement_node.parent.nil?)
      session[key] = statement_node.echoable? ?
                     statement_node.sibling_statements(@language_preference_list).map(&:id) :
                     [statement_node.id]
    end

    # Store last statement in session (for cancel link)
    session[:last_statement_node] = statement_node.id if reload
  end

  #
  # show "being edited" info message
  #
  def being_edited(format)
    set_error('discuss.statements.staled_modification')
    format.html { flash_error and redirect_to url_for(@statement_node) }
    format.js { show }
  end

  def with_info(opts={})
    respond_to do |format|
      yield format if block_given?
      format.html { flash_info and render :template => opts[:template] }
      format.js   { render_with_info }
    end
  end

  def log_statement_error(e, message)
    log_message_error(e, message) do |format|
      flash_error and redirect_to url_for(@statement_node)
    end
  end

  def log_home_error(e, message)
    log_message_error(e, message) do |format|
      flash_error and redirect_to_home
    end
  end
end
