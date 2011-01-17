class StatementsController < ApplicationController
  
  verify :method => :get, :only => [:index, :show, :new, :edit, :category, :new_translation,
                                    :more, :children, :authors, :add, :ancestors]
  verify :method => :post, :only => [:create]
  verify :method => :put, :only => [:update, :create_translation, :publish]
  verify :method => :delete, :only => [:destroy]
  
  # The order of these filters matters. change with caution.
  skip_before_filter :require_user, :only => [:category, :show, :more, :children, :authors, :add, :ancestors,
                                              :redirect_to_statement]
  
  before_filter :fetch_statement_node, :except => [:category, :my_issues, :new, :create]
  before_filter :fetch_statement_node_type, :only => [:new, :create]
  before_filter :redirect_if_approved_or_incorporated, :only => [:show, :edit, :update, :destroy,
                                                                 :new_translation, :create_translation,
                                                                 :echo, :unecho]
  before_filter :fetch_languages, :except => [:destroy, :redirect_to_statement, :ancestors]
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
    allow :admin
    allow logged_in, :editor, :except => [:destroy]
    allow anonymous, :to => [:index, :show, :category, :more, :children, :authors, :add,:ancestors]
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
    
#    begin
      # Get document to show or redirect if not found
      @statement_document ||= @statement_node.document_in_preferred_language(@language_preference_list)
      if @statement_document.nil?
        redirect_to_url discuss_search_url, 'discuss.statements.no_document_in_language'
      end
      
      # Record visited
      @statement_node.visited!(current_user) if current_user
      
      # Transfer statement node data to client for prev/next functionality
      load_siblings(@statement_node) if !params[:new_level].blank?
      
      # Test for special links
      @set_language_skills_teaser = @statement_node.not_original_language?(current_user, @locale_language_id)
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
      
      render_template 'statements/show'
#    rescue Exception => e
#      log_error_home(e, "Error showing statement.")
#    end
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
    
    #search terms as tags
    loadSearchTermsAsTags(params[:origin]) if @statement_node.taggable? and params[:origin]
    
    # set new breadcrumb
    if @statement_node.class.is_top_statement?
      set_parent_breadcrumb
      load_origin_statement
    end
    
    load_echo_messages if @statement_node.echoable?
    
    render_template 'statements/new'
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
      parent_node_id = attrs[:parent_id]
      attrs.merge!({:root_id => StatementNode.find(parent_node_id).root_id}) if !parent_node_id.blank?
      
      # Preapre in memory
      @statement_node ||= @statement_node_type.new_instance(attrs)
      @statement_document = @statement_node.add_statement_document(
                            doc_attrs.merge({:original_language_id => doc_attrs[:language_id],
                                             :author_id => current_user.id,
                                             :current => true}))
      
      
      @tags = []
      has_permission = true
      created = false
       
      if @statement_node.taggable? and (has_permission = check_hash_tag_permissions(form_tags))
        @tags = @statement_node.topic_tags = form_tags
      end
       
      # Persisting
      if has_permission
        StatementNode.transaction do
          if @statement_node.save
            # add to tree
            if parent_node_id.blank? or @statement_node.class.is_top_statement?
              @statement_node.target_statement.update_attribute(:root_id, @statement_node.target_id)
            end 

            if @statement_node.echoable?
              echo = params.delete(:echo)
              @statement_node.author_support if echo=='true'
            end
            
            # Propagating the creation event
            EchoService.instance.created(@statement_node)
            created = true
          end
        end
      end
      
      # Rendering
      if has_permission and created
        load_siblings @statement_node
        load_all_children
        
        set_statement_info @statement_document
        show_statement do
          render :template => 'statements/create'
        end
      else
        set_error(@statement_document)
        render_statement_with_error :template => 'statements/new'
      end
      
    rescue Exception => e
      log_message_error(e, "Error creating statement node.") do
        load_ancestors and flash_error and render :template => 'statements/new'
      end
    else
      log_message_info("Statement node has been created sucessfully.") if created
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
      set_statement_info 'discuss.statements.statement_updated'
      render_statement_with_info
    elsif !has_lock
      set_info 'discuss.statements.being_edited'
      render_statement_with_info
    else
      render_template 'statements/edit'
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
      has_permission = form_tags.nil? || !@statement_node.taggable? || check_hash_tag_permissions(form_tags)
      
      holds_lock = true
      if has_permission
        StatementNode.transaction do
          old_statement_document = StatementDocument.find(attrs_doc[:old_document_id])
          holds_lock = holds_lock?(old_statement_document, locked_at)
          if holds_lock
            old_statement_document.update_attribute(:current, false)
            old_statement_document.save!
            @statement_document = @statement_node.add_statement_document(
                                    attrs_doc.merge({:author_id => current_user.id,
                                                     :current => true}))
            @statement_document.save
            
            if @statement_node.taggable? and form_tags
              @tags = @statement_node.topic_tags = form_tags
            end
            @statement_node.save
          end
        end
      end
      
      if !holds_lock
        being_edited
      elsif has_permission and @statement_node.valid? and @statement_document.valid?
        update = true
        set_statement_info(@statement_document)
        show_statement
      else
        set_error(@statement_document) if @statement_document
        set_error(@statement_node)
        show_statement true
      end
      
    rescue Exception => e
      log_error_statement(e, "Error updating statement node '#{@statement_node.id}'.")
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
    show_statement
  end
  
  
  ###################
  # STATEMENT IMAGE #
  ###################
  
  
  # Loads the authors of this statement to the view
  #
  # Method:   GET
  # Response: JS
  #
  def authors
    load_authors
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
  def children
    @type = params[:type].camelize || @statement_node.class.children_types.first.to_s
    load_top_children(@type)
    respond_to do |format|
      format.js { render :template => @type.constantize.children_template }
    end
  end
  
  #
  # Loads more children into the right children pane (lazy pagination).
  #
  # Method:   GET
  # Params:   page: integer, type: string
  # Response: JS
  #
  def more
    @type = params[:type].camelize || @statement_node.class.children_types.first.to_s
    @page = params[:page] || 1
    @per_page = MORE_CHILDREN
    @offset = @page.to_i == 1 ? TOP_CHILDREN : 0
    load_children @type
    respond_to do |format|
      format.js {render :template => @type.constantize.more_template}
    end
  end
  
  #
  # Shows add statement teaser page.
  #
  # Method:   GET
  # Params:   type: string
  # Response: HTTP or JS
  #
  def add
    @type = params[:type].to_s
    if !params[:new_level].blank?
      if @statement_node # this is the teaser's parent (e.g.: 1212345/add/proposal)
        load_children_for_parent @statement_node, @type
      else # this is the question's teaser (e.g.: /add/question
        load_roots_to_session
      end
    end
    begin
      render_template('statements/add', true)
    rescue Exception => e
      log_error_home(e, "Error showing add #{@type} teaser.")
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
      set_statement_info("discuss.messages.deleted")
      flash_info
      redirect_to(@statement_node.parent ? statement_node_url(@statement_node.parent) : discuss_search_url)
    rescue Exception => e
      log_message_error(e, "Error deleting statement node '#{@statement_node.id}'.") do
        flash_error and redirect_to_statement
      end
    else
      log_message_info("Statement node '#{@statement_node.id}' has been deleted successfully.")
    end
  end
  
  ###############
  # REDIRECTION #
  ###############
  
  def redirect_to_statement
    options = {}
    %w(origin search_terms prev bids sids).each{|s| options[s] = params[s]}
    redirect_to statement_node_url(@statement_node.target_statement, options)
  end
  
  ##############
  # BREADCRUMB #
  ##############
  
  def ancestors
    statement_ids = @statement_node.self_and_ancestors.map(&:id)
    respond_to do |format|
      format.json{render :json => statement_ids}
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
    children_types = @statement_node.class.children_types(true).transpose
    if !children_types.empty?
      types = children_types[0]
      @children_documents = {}
      types.each_with_index do |type, index|
        immediate_render = children_types[1][index]
        if immediate_render
          @children[type] = @statement_node.get_paginated_child_statements(@language_preference_list, type.to_s)
          @children_documents.merge!(search_statement_documents(@children[type].flatten.map(&:statement_id),
                                                                @language_preference_list))
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
    @children = @statement_node.get_paginated_child_statements(@language_preference_list,
                                                               type.to_s, page, per_page)
    @children_documents = search_statement_documents(@children.flatten.map(&:statement_id),
                                                     @language_preference_list)
  end
  
  #
  # Load the authors of the current statement for rendering.
  #
  def load_authors
    @authors = @statement_node.authors
  end
  
  
  #####################
  # Editing / Locking #
  #####################
  
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
  # FILTERS #
  ###########
  
  private
  
  #
  # Gets the correspondent statement node to the id that is given in the request.
  #
  def fetch_statement_node
    @statement_node ||= StatementNode.find(params[:id]) if params[:id].try(:any?) && params[:id] =~ /\d+/
  end
  
  #
  # Gets the correspondent statement node type to be used in the forms.
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
      log_error_home(e,"Error running redirect approved/incorporated IP filter")
    end
  end
  
  #
  # Loads the locale language and the language preference list.
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
      document_param = params[statement_node_symbol][:new_statement_document] ||
                       params[statement_node_symbol][:statement_document]
      text = document_param[:text]
      document_param[:text] = "" if text.eql?('<br>')
    end
  end
  
  #
  # Returns the statement node corresponding symbol (:question, :proposal...).
  #
  def statement_node_symbol
    klass = @statement_node_type.nil? ? @statement_node.class : @statement_node_type
    klass.name.underscore.to_sym
  end
  
  #
  # Returns the parent statement node of the current statement.
  #
  def parent
    params.has_key?(:id) ? StatementNode.find(params[:id]) : nil
  end
  
  
  ######################
  # BREADCRUMB HELPERS #
  ######################
  
  
  #
  # Sets the breadcrumb of the current statement node's parent.
  #
  def set_parent_breadcrumb
    return if @statement_node.parent.nil?
    parent_node = @statement_node.parent
    statement_documents = search_statement_documents(parent_node.statement_id,
                                                     @language_preference_list)
    #[id, classes, url, title]                                                     
    @breadcrumb = ["#{parent_node.class.name.underscore}_#{parent_node.id}",
                   "statement statement_link #{parent_node.class.name.underscore}_link",
                   statement_node_url(parent_node),
                   statement_documents[parent_node.statement_id].title]
  end
  
  #
  # Sets the breadcrumbs for the current statement node view previous path.
  #
  def load_breadcrumbs
    return if params[:bids].blank?
    
    # get bids into an array structure
    bids = params[:bids].split(',')
    bids = bids.map{|b|b.split('=>')}
    
    @breadcrumbs = []
    
    bids.each do |bid| #[id, classes, url, title]
      @breadcrumbs << case bid[0]
        when "ds" then ["ds","search_link statement_link", discuss_search_url, I18n.t("discuss.statements.breadcrumbs.discuss_search")]
        when "sr" then ["sr","search_link statement_link", discuss_search_url(:origin => :discuss_search, :search_terms => bid[1].gsub(/\\\\/, ',')), I18n.t("discuss.statements.breadcrumbs.discuss_search_with_value", :value => bid[1])]        when "mi" then ["mi","search_link statement_link", my_issues_url, I18n.t("discuss.statements.breadcrumbs.my_issues")]
        when "fq" then statement_node = StatementNode.find(bid[1])
        statement_document = search_statement_documents(statement_node.statement_id, @language_preference_list)
        ["#{statement_node.class.name.underscore}_#{bid[1]}", 
                        "statement statement_link #{statement_node.class.name.underscore}_link", 
        statement_node_url(statement_node), statement_document[statement_node.statement_id].title]
      end
    end
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
  def search_statement_nodes(opts = {})
    StatementNode.search_statement_nodes(opts.merge({:type => "Question"}))
  end
  
  #
  # Gets all the statement documents belonging to a group of statements, and orders them per language ids.
  #
  def search_statement_documents(statement_ids, language_ids = @language_preference_list)
    statement_documents = StatementDocument.search_statement_documents(statement_ids, language_ids).sort! {|a, b|
      language_ids.index(a.language_id) <=> language_ids.index(b.language_id)
    }
    statement_documents.each_with_object({}) do |sd, documents_hash|
      documents_hash[sd.statement_id] = sd unless documents_hash.has_key?(sd.statement_id)
    end
  end
  
  
  
  
  
  ############################
  # SESSION HANDLING HELPERS #
  ############################
  
  def load_origin_statement
    @previous_node = @statement_node.parent
    @previous_type = case @statement_node.class.name 
      when "FollowUpQuestion" then "fq"
    end
  end

  
  #
  # Loads the ancestors of the current statement node, in order to display the correct context. Only used for HTTP.
  # When teaser=true, @statement_node is the PARENT node of the teaser.
  #
  def load_ancestors(teaser = false)
    if @statement_node
      @ancestors = @statement_node.ancestors
      @ancestors.each {|a| load_siblings(a) }
      
      load_siblings(@statement_node) # if teaser: @statement_node is the teaser's parent, otherwise the node on the bottom-most level
      if teaser
        @ancestors << @statement_node # if teaser: @statement_node is the teaser's parent, therefore, an ancestor
        load_children_for_parent(@statement_node, @type)
      end
    else
      if teaser
        load_roots_to_session
      else
        @ancestors = []
      end
    end
  end
  
  def load_children_for_parent(statement_node, type)
    @siblings ||= {}
    class_name = type.classify
    siblings = statement_node.children_to_session(@language_preference_list,class_name)
    @siblings["add_#{type}"] = siblings
  end
  
  #
  # Loads siblings of the current statement node.
  #
  def load_siblings(statement_node)
    @siblings ||= {}
    class_name = statement_node.target_statement.class.name.underscore
    # if has parent then load siblings
    if statement_node.parent_id
      siblings = statement_node.siblings_to_session(@language_preference_list)
    else #else, it's a root node
      siblings = roots_to_session(statement_node)
    end
    @siblings["#{class_name}_#{statement_node.target_id}"] = siblings
  end
  
  #
  # Only for HTTP and add question teaser.
  #
  def load_roots_to_session
    @siblings ||= {}
    @siblings["add_question"] = roots_to_session(@statement_node)
  end
  
  #
  # Gets the root ids that need to be loaded to the session.
  #
  def roots_to_session(statement_node)
    if params[:origin] #statement node is a question
      origin = params[:origin].split("=>")
      siblings = case origin[0]
        when 'ds' then search_statement_nodes(:search_term => "", :language_ids => @language_preference_list,
                                              :show_unpublished => current_user && current_user.has_role?(:editor)).map(&:id) + ["/add/question"]
        when 'sr'then search_statement_nodes(:search_term => origin[1].gsub(/\\\\/,','),
                                             :language_ids => @language_preference_list,
                                             :show_unpublished => current_user && current_user.has_role?(:editor)).map(&:id) + ["/add/question"]
        when 'mi' then current_user.get_my_issues.map(&:id) + ["/add/question"]
        when 'fq' then @previous_node = StatementNode.find(origin[1])
                       @previous_type = "FollowUpQuestion"
                       @previous_node.child_statements(@language_preference_list, @previous_type, true)
      end
    else
      siblings = (statement_node ? [statement_node.id] : []) + ["/add/question"]
    end
    siblings
  end
  
  
  ####################
  # RESPONSE RENDERS #
  ####################
  
  %w(info error).each do |type|
    class_eval %(
      def render_statement_with_#{type}(opts={}, &block)
        respond_to do |format|
          format.html do
            flash_#{type}
            opts[:template] ? (render :template => opts[:template]) : show
          end
          format.js { render_with_#{type} &block }
        end
      end
    )
  end
  
  def show_statement(errors = false)
    respond_to do |format|
      format.html {
        errors ? flash_error : flash_info
        redirect_to_statement
      }
      format.js {
        block_given? ? yield : (errors ? render_with_error : show)
      }
    end
  end
  
  def render_template(template, teaser = false)
    respond_to do |format|
      format.html {
        load_breadcrumbs
        load_ancestors(teaser)
        render :template => template
      }
      format.js {
        load_ancestors(teaser) if !params[:sids].blank? or (!params[:new_level].blank? and (@statement_node.nil? or @statement_node.level == 0))
        load_breadcrumbs if !params[:bids].blank?
        render :template => template
      }
    end
  end
  
  ########
  # MISC #
  ########
  
  #
  # Sets the info to displayed along with the response.
  # The action name is automagically incorporated into the I18n key.
  #
  def set_statement_info(object)
    code = object.kind_of?(String) ? object : "discuss.messages.#{object.action.code}"
    set_info code, :type => I18n.t("discuss.statements.types.#{@statement_node.class.name.underscore}")
  end
  
  #
  # Loads search terms from the search as tags for the statement node.
  #
  def loadSearchTermsAsTags(origin)
    origin = origin.split('=>')
    return if !origin[0].eql?('sr')
    default_tags = origin[1]
    default_tags[/[\s]+/] = ',' if default_tags[/[\s]+/] 
    default_tags = default_tags.split(',').compact
    default_tags.each{|t| @statement_node.topic_tags << t }
    @tags ||= @statement_node.topic_tags if @statement_node.taggable?
  end
  
  #
  # Shows "being edited" info message and refreshes the statement.
  #
  def being_edited
    respond_to do |format|
      set_error('discuss.statements.staled_modification')
      format.html { flash_error and redirect_to_statement }
      format.js { show }
    end
  end
  
  ###########
  # LOGGERS #
  ###########
  
  # Logs the exception and redirects to the statement.
  def log_error_statement(e, message)
    log_message_error(e, message) do
      flash_error and redirect_to_statement
    end
  end
  
  # Logs the exception and redirects to home.
  def log_error_home(e, message)
    log_message_error(e, message) do
      flash_error and redirect_to_home
    end
  end
end
