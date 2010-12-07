class StatementsController < ApplicationController
  verify :method => :get, :only => [:index, :show, :new, :edit, :category, :new_translation,
                                    :more, :children, :upload_image, :reload_image, :authors, :add, :parents]
  verify :method => :post, :only => [:create]
  verify :method => :put, :only => [:update, :create_translation, :publish]
  verify :method => :delete, :only => [:destroy]

  # The order of these filters matters. change with caution.
  skip_before_filter :require_user, :only => [:category, :show, :more, :children, :authors, :redirect, :add, :parents]

  before_filter :fetch_statement_node, :except => [:category, :my_discussions, :new, :create]
  before_filter :fetch_statement_node_type, :only => [:new, :create]
  before_filter :redirect_if_approved_or_incorporated, :except => [:category, :my_discussions,
                                                                   :new, :create, :more, :children, :upload_image,
                                                                   :reload_image, :redirect, :authors, :add, :parents]
  before_filter :fetch_languages, :except => [:destroy, :redirect, :parents]
  before_filter :require_decision_making_permission, :only => [:echo, :unecho, :new, :new_translation]
  before_filter :check_empty_text, :only => [:create, :update, :create_translation]

  include PublishableModule
  before_filter :is_publishable?, :only => [:publish]
  include EchoableModule
  before_filter :is_echoable?, :only => [:echo, :unecho]
  include TranslationModule
  include IncorporationModule
  before_filter :is_draftable?, :only => [:incorporate]

  # Authlogic access control block
  access_control do
    allow :editor
    allow anonymous, :to => [:index, :show, :category, :more, :children, :authors, :add,:parents]
    allow logged_in
  end


  ##############
  # ATTRIBUTES #
  ##############

  @@edit_locking_time = 1.hours

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
      load_siblings(@statement_node) if !params[:new_level].blank?

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
      load_all_children

      respond_action 'statements/show'
    rescue Exception => e
      log_home_error(e,"Error showing statement.")
    end
  end

  #
  # Renders form for creating a new statement.
  #
  # Method:   GET
  # Params:   parent_id: integer
  # Response: JS
  #
  def new
    @statement_node ||= @statement_node_type.new_instance(:parent_id => params[:id],
                                                          :editorial_state => StatementState[:new])
    @statement_document ||= StatementDocument.new(:language_id => @locale_language_id)
    @action ||= StatementAction["created"]
    @statement_node.topic_tags << "#{params[:value]}" if params[:value]
    @tags ||= @statement_node.topic_tags if @statement_node.taggable?

    load_echo_messages if @statement_node.echoable?

    respond_action 'statements/new'
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
    form_tags = attrs.delete(:topic_tags)

    begin
      @statement_node ||= @statement_node_type.new_instance(attrs)
      @statement_node.statement ||= Statement.new
      @statement_document = @statement_node.add_statement_document(
                            doc_attrs.merge({:original_language_id => doc_attrs[:language_id],
                                             :author_id => current_user.id,
                                             :current => true}))
      permitted = true ; @tags = []
      if @statement_node.taggable? and (permitted = check_hash_tag_permissions(form_tags))
        @statement_node.topic_tags=form_tags
        @tags=@statement_node.topic_tags
      end
      if permitted and @statement_node.save and @statement_node.statement.save
        if @statement_node.echoable?
          echo = params.delete(:echo).parameterize
          @statement_node.author_support if echo==true
        end
        EchoService.instance.created(@statement_node)
        set_statement_node_info(@statement_document)
        # load siblings to store in client session
        load_siblings(@statement_node)
        load_all_children

        #if top statement, then load parent and title
        set_parent_breadcrumb if @statement_node.class.is_top_statement?

        respond_to_statement do |format|
          format.js {render :template => 'statements/create'}
        end
      else
        set_error(@statement_document)
        render_with_error :template => 'statements/new'
      end
    rescue Exception => e
      log_message_error(e, "Error creating statement node.") do |format|
        with_info format, :template => 'statements/new'
      end
    else
      log_message_info("Statement node has been created sucessfully.") if @statement_node
    end
  end


  #
  # Renders a form to edit the current statement.
  #
  # Method:   GET
  # Params:   id: integer
  # Response: JS
  #
  def edit
    @statement_document ||= @statement_node.document_in_preferred_language(@language_preference_list)
    @tags ||= @statement_node.topic_tags if @statement_node.taggable?
    if (is_current_document = (@statement_document.id == params[:current_document_id].to_i))
      has_lock = acquire_lock(@statement_document)
      @action ||= StatementAction["updated"]
    end

    if !is_current_document
      render_with_info(:template => 'statements/edit' ) do |format|
        set_statement_node_info(nil, 'discuss.statements.statement_updated')
      end
    elsif has_lock
      respond_action 'statements/edit'
    else
      render_with_info(:template => 'statements/edit' ) do |format|
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
      form_tags = attrs.delete(:topic_tags)
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
                                                       :author_id => current_user.id,
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
            @statement_node.statement.save
            update_image = true
          end
        end
      end

      if attrs_doc #normal form POST
        if !holds_lock
            being_edited
        elsif has_tag_permissions and @statement_node.valid? and @statement_document.valid?
          update = true
          set_statement_node_info(@statement_document)
          respond_to_statement
        else
          set_error(@statement_document) if @statement_document
          set_error(@statement_node)
          respond_to_statement false
        end
      else
        respond_to_statement
      end
    rescue Exception => e
      log_statement_error(e, "Error updating statement node '#{@statement_node.id}'.")
    else
      log_message_info("Statement node '#{@statement_node.id}' has been updated sucessfully.") if update
      log_message_info("Statement node '#{@statement_node.id}' has a new image.") if update_image
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
    respond_to_statement
  end


  ###################
  # STATEMENT IMAGE #
  ###################

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
  #  1. login_container with users picture as profile link
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
          show_info_messages do |page|
            page << "$('#statements div.#{dom_class(@statement_node)} #statement_image').replaceWith('#{render :partial => 'statements/image'}')"
            page << "$('#statements div.#{dom_class(@statement_node)} #upload_link').remove()" if @statement_node.published?
          end
        }
      else
        set_error('discuss.statements.upload_image.error')
        format.js { show_error_messages }
      end
    end
  end

  # Loads the authors of this statement to the view
  #
  # Method:   GET
  # Response: JS
  #
  def authors
    set_authors
    respond_to do |format|
      format.js {render :template => 'statements/authors'}
    end
  end

  #
  # Loads a certain children pane that had been previously hidden.
  #
  # Method:   GET
  # Params:   type: string
  # Response: JS
  #
  def more
    @type = params[:type].camelize || @statement_node.class.expected_children_types.first.to_s
    load_top_children(@type)
    respond_to do |format|
      format.js {render :template => @type.constantize.more_template}
    end
  end

  #
  # Loads more children into the right children pane (lazy pagination).
  #
  # Method:   GET
  # Params:   page: integer, type: string
  # Response: JS
  #
  def children
    @type = params[:type].camelize || @statement_node.class.expected_children_types.first.to_s
    @page = params[:page] || 1
    @per_page = 7
    @offset = @page.to_i == 1 ? TOP_CHILDREN : 0
    load_children(@type)
    respond_to do |format|
      format.js {render :template => @type.constantize.children_template}
    end
  end



  # Shows an add statement teaser page
  #
  # Method:   GET
  # Params:   type: string
  # Response: HTTP or JS
  #
  def add
    @type = params[:type].to_s
    begin
      respond_action('statements/add', true)
    rescue Exception => e
      log_home_error(e,"Error showing add #{@type} teaser.")
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
      flash_info and redirect_to :controller => :statements,
                                 :action => :category,
                                 :id => params[:category]
    rescue Exception => e
      log_message_error(e, "Error deleting statement node '#{@statement_node.id}'.") do |format|
        format.html { flash_error and redirect_to statement_node_url(@statement_node) }
      end
    else
      log_message_info("Statement node '#{@statement_node.id}' has been deleted sucessfully.")
    end
  end

  ###############
  # REDIRECTION #
  ###############

  def redirect
    redirect_to statement_node_url(@statement_node)
  end

  ##############
  # BREADCRUMB #
  ##############

  def parents
    sid = @statement_node.self_and_ancestors.map(&:id)
    respond_to do |format|
      format.json{render :json => sid}
    end
  end

  #############
  # PROTECTED #
  #############

  protected

  #
  # Loads the children of the current statement, storing them in an hash by type
  #
  def load_all_children
    @children = {}
    children_types_with_visibility = @statement_node.class.expected_children_types(true).transpose
    if !children_types_with_visibility.empty?
      types = children_types_with_visibility[0]
      types.each_with_index do |type, index|
        visibility = children_types_with_visibility[1][index]
        if visibility
          type_class = type.to_s.constantize
          @children[type] = @statement_node.get_paginated_child_statements(@language_preference_list, type.to_s)
          @children_documents = search_statement_documents(@children[type].map(&:statement_id),
                                                         @language_preference_list)
        else
          @children[type] = nil
        end
      end
    end
  end

  def load_top_children(type)
    load_children(type, 1, TOP_CHILDREN)
  end

  #
  # Loads the children of the current statement from a certain type
  #
  def load_children(type, page = @page, per_page = @per_page)
    @children = @statement_node.get_paginated_child_statements(@language_preference_list, type.to_s, page, per_page)
    @children_documents = search_statement_documents(@children.flatten.map { |s| s.statement_id },
                                                     @language_preference_list)
  end

  #
  # Sets the authors of the current statement
  #
  def set_authors
    @authors = @statement_node.authors
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
    @statement_node ||= StatementNode.find(params[:id]) if params[:id].try(:any?) && params[:id] =~ /\d+/
  end

  #
  # Gets the correspondent statement node type to be used in the forms
  #
  def fetch_statement_node_type
    @statement_node_type = params[:type] ? params[:type].to_s.classify.constantize : nil
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
    if params[statement_node_symbol].include? :new_statement_document or params[statement_node_symbol].include? :statement_document
      document_param = params[statement_node_symbol][:new_statement_document] || params[statement_node_symbol][:statement_document]
      text = document_param[:text]
      document_param[:text] = "" if text.eql?('<br>')
    end
  end

  #
  # Returns the statement node correspondent symbol (:discussion, :proposal...).
  #
  def statement_node_symbol
    symbol = @statement_node_type.nil? ? @statement_node.class : @statement_node_type
    symbol.name.underscore.to_sym
  end

  #
  # Returns the parent statement node of the current statement.
  #
  def parent
    params.has_key?(:id) ? StatementNode.find(params[:id]) : nil
  end

  #
  # Sets the info to displayed along with the response.
  # The action name is automagically incorporated into the I18n key.
  #
  def set_statement_node_info(statement_document, string=nil, statement_node = @statement_node)
    set_info((string || "discuss.messages.#{statement_document.action.code}"),
             :type => I18n.t("discuss.statements.types.#{statement_node.class.name.underscore}"))
  end

  #
  # Sets the ancestors of the current statement node, in order to write the correct context down
  #
  def set_ancestors(teaser = false)
    if @statement_node
      @ancestors = @statement_node.ancestors
      @ancestors.each{|a|load_siblings(a)}

      # current statement node siblings must be loaded also on http request
      load_siblings(@statement_node)
      if teaser
        @ancestors << @statement_node
        load_children_from_parent(@statement_node, @type)
      end
    else
      if teaser
        load_roots_to_session
      else
        @ancestors = []
      end
    end
  end

  #
  # Sets the new breadcrumb of the current statement node
  #
  def set_breadcrumbs
    breadcrumbs = params[:breadcrumb].split(",")
    statement_nodes = StatementNode.find(breadcrumbs)
    statement_documents = search_statement_documents(statement_nodes.map(&:statement_id), @language_preference_list)
    @breadcrumbs = statement_nodes.map{|n|[n.class.name.underscore, n.id, statement_node_url(n), statement_documents[n.statement_id].title]}
  end

  #
  # Sets the breadcrumb of the current statement node's parent
  #
  def set_parent_breadcrumb
    parent_node = @statement_node.parent
    statement_documents = search_statement_documents(parent_node.statement_id, @language_preference_list)
    @breadcrumb = [parent_node.class.name.underscore, parent_node.id, statement_node_url(parent_node), statement_documents[parent_node.statement_id].title]
  end

  #
  # Sets the breadcrumbs for the current statement node view previous path
  #
  def initialize_breadcrumbs
    add_breadcrumb I18n.t("discuss.statements.breadcrumbs.#{params[:path]}"), "#{params[:path]}_path" if params[:path]
    add_breadcrumb I18n.t("discuss.statements.breadcrumbs.#{params[:path]}_with_value", :value => params[:value]), discuss_search_with_value_path(params[:value]) if params[:value]
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
          format.html { flash_info and redirect_to(statement_node_url(statement)) }
          format.js do
            show_info_messages
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
  # Calls the statement node sql query for discussions.
  #
  def search_statement_nodes (opts = {})
    StatementNode.search_statement_nodes(opts.merge({:type => "Discussion"}))
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
  # Loads siblings of the current statement node
  #
  def load_siblings(statement_node)
    @siblings ||= {}
    class_name = statement_node.class.to_s.underscore
    # if has parent, then load siblings
    if statement_node.parent_id
      siblings = statement_node.siblings_to_session(@language_preference_list)
    else #else, it's a root node
      siblings = get_roots_to_session(statement_node)
    end
    @siblings["#{class_name}_#{statement_node.id}"] = siblings
  end

  def load_children_from_parent(statement_node, type)
    @siblings ||= {}
    class_name = type.classify
    siblings = statement_node.children_to_session(@language_preference_list,class_name)
    @siblings["add_#{type}"] = siblings
  end

  def load_roots_to_session
    @siblings ||= {}
    @siblings["add_discussion"] = get_roots_to_session(@statement_node)
  end

  #gets the root ids that need to be loaded to the session
  def get_roots_to_session(statement_node)
    if params[:path]
      siblings = case params[:path]
        when 'discuss_search' then search_statement_nodes(:search_term => params[:value]||"", :language_ids => @language_preference_list,
                                                          :show_unpublished => current_user && current_user.has_role?(:editor)).map(&:id)
        when 'my_discussions' then current_user.get_my_discussions.map(&:id)
      end
    else
      siblings = statement_node ? [statement_node.id] : []
    end
    siblings + ["/add/discussion"]
  end

  #
  # show "being edited" info message
  #
  def being_edited
    respond_to do |format|
      set_error('discuss.statements.staled_modification')
      format.html { flash_error and redirect_to statement_node_url(@statement_node) }
      format.js { show }
    end
  end

  %w(info error).each do |type|
    class_eval %(
      def render_with_#{type}(opts={})
        respond_to do |format|
          yield format if block_given?
          with_#{type} format, :template => opts[:template]
          format.js   { show_#{type}_messages }
        end
      end

      def with_#{type}(format, opts={})
        format.html { set_ancestors
                      flash_#{type}
                      render :template => opts[:template] }
      end
    )
  end


  def respond_to_statement(no_errors = true)
    respond_to do |format|
      format.html {
        (no_errors ? flash_info : flash_error)
        redirect_to statement_node_url(@statement_node)
      }
      block_given? ? yield(format) : format.js {no_errors ? show : show_error_messages}
    end
  end

  def respond_action(template, teaser = false)
    respond_to do |format|
      yield format if block_given?
      format.html {
        initialize_breadcrumbs
        set_ancestors(teaser)
        render :template => template
      }
      format.js {
        set_ancestors(teaser) if !params[:sid].blank? or teaser or @statement_node.class.is_top_statement?
        set_breadcrumbs if !params[:breadcrumb].blank?
        render :template => template
      }
    end
  end


  def log_statement_error(e, message)
    log_message_error(e, message) do |format|
      flash_error and redirect_to statement_node_url(@statement_node)
    end
  end

  def log_home_error(e, message)
    log_message_error(e, message) do |format|
      flash_error and redirect_to_home
    end
  end
end
