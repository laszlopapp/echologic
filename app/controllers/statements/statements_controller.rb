class StatementsController < ApplicationController

  verify :method => :get, :only => [:index, :show, :new, :edit, :category, :new_translation,
                                    :more, :children, :authors, :add, :ancestors, :descendants, :social_widget]
  verify :method => :post, :only => [:create, :share]
  verify :method => :put, :only => [:update, :create_translation, :publish]
  verify :method => :delete, :only => [:destroy]

  # The order of these filters matters. change with caution.
  skip_before_filter :require_user, :only => [:category, :show, :more, :children, :add, :ancestors, :descendants,
                                              :redirect_to_statement]

  before_filter :fetch_statement_node, :except => [:category, :my_questions, :new, :create]
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
  before_filter :is_echoable?, :only => [:echo, :unecho, :social_widget, :share]
  include TranslationModule
  include IncorporationModule
  before_filter :is_draftable?, :only => [:incorporate]

  # Authlogic access control block
  access_control do
    allow :admin
    allow logged_in, :editor, :except => [:destroy]
    allow anonymous, :to => [:index, :show, :category, :more, :children, :authors, :add, :ancestors, :descendants]
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

      # If statement node is draftable, then try to get the approved one
      load_approved_statement

      # Find all child statement_nodes, which are published (except user is an editor)
      # sorted by supporters count, and paginate them
      load_all_children

      render_template 'statements/show'
    rescue Exception => e
      log_error_home(e, "Error showing statement.")
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

    #search terms as tags
    if @statement_node.taggable?
      @statement_node.load_root_tags if @statement_node.class.is_top_statement?
      loadSearchTermsAsTags(params[:origin]) if params[:origin]
    end

    # set new breadcrumb
    if @statement_node.class.is_top_statement? and !params[:new_level].blank?
      set_parent_breadcrumb
      load_origin_statement
    end

    load_echo_info_messages if @statement_node.echoable?

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


      # Prepare in memory
      @statement_node ||= @statement_node_type.new_instance(attrs)
      @statement_document = @statement_node.add_statement_document(
                            doc_attrs.merge({:original_language_id => doc_attrs[:language_id],
                                             :author_id => current_user.id,
                                             :current => true}))

      @tags = []
      has_permission = true
      created = false

      if @statement_node.taggable?
        @tags = @statement_node.topic_tags = form_tags
      end



      # Persisting
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
          EchoService.instance.created(@statement_node.question) if @statement_node.question_id
          created = true
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

    if !current_user.may_edit? @statement_node
      set_statement_info 'discuss.statements.cannot_be_edited'
      render_statement_with_info
    elsif !is_current_document
      set_statement_info 'discuss.statements.statement_updated'
      show
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

      holds_lock = true
      StatementNode.transaction do
        old_statement_document = StatementDocument.find(attrs_doc[:old_document_id])
        holds_lock = holds_lock?(old_statement_document, locked_at)
        if holds_lock
          old_statement_document.current = false
          old_statement_document.unlock # also saved the document
          @statement_document = @statement_node.add_statement_document(
                                  attrs_doc.merge({:author_id => current_user.id,
                                                   :current => true}))
          @statement_document.save

          @statement_node.update_attributes(attrs)
          if @statement_node.taggable? and form_tags
            @tags = @statement_node.topic_tags = form_tags
          end
          @statement_node.statement.save
        end
      end

      if !holds_lock
        being_edited
      elsif @statement_node.valid? and @statement_document.valid?
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
    @statement_document = @statement_node.document_in_preferred_language(@language_preference_list)
    if holds_lock?(@statement_document, locked_at)
      @statement_document.unlock
    end
    show_statement
  end

  # Loads the authors of this statement to the view
  #
  # Method:   GET
  # Response: JS
  #
  def authors
    begin
      load_authors
      respond_to do |format|
        format.html{show}
        format.js {render :template => 'statements/authors'}
      end
    rescue Exception => e
      log_error_home(e, "Error loading authors of statement node #{@statement_node ? @statement_node.id : params[:id]}.")
    end
  end

  #
  # Loads a certain siblings pane that had been previously hidden.
  #
  # Method:   GET
  # Params:   id : parent node id ; type: string
  # Response: JS
  #
  def descendants
    @type = params[:type].to_s.camelize.to_sym
    @current_node = StatementNode.find(params[:current_node]) if params[:current_node]
    begin
      @statement_node ? load_children(:type => @type, :per_page => -1) : load_roots(:node => @current_node, :per_page => -1)

      respond_to do |format|
        format.html{
          if @current_node
            @statement_node = @current_node
            show
          else
            add
          end
        }
        format.js { render :template => @type.to_s.constantize.descendants_template }
      end
    rescue Exception => e
      log_error_home(e, "Error loading descendants of type #{@type}.")
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
    @type = params[:type].camelize.to_sym
    begin
      load_children :type => @type
      respond_to do |format|
        format.html{show}
        format.js { render :template => @type.to_s.constantize.children_template }
      end
    rescue Exception => e
      log_error_home(e, "Error loading children of type #{@type}.")
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
    @type = params[:type].camelize.to_sym
    @page = params[:page] || 1
    @per_page = MORE_CHILDREN
    @offset = @page.to_i == 1 ? TOP_CHILDREN : 0
    begin
      load_children :type => @type, :page => @page, :per_page => @per_page
      respond_to do |format|
        format.html{show}
        format.js {render :template => @type.to_s.constantize.more_template}
      end
    rescue Exception => e
      log_error_home(e, "Error loading more children of type #{@type}.")
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
    begin
      if !params[:new_level].blank?
        if @statement_node # this is the teaser's parent (e.g.: 1212345/add/proposal)
          load_children_for_parent @statement_node, @type
        else # this is the question's teaser (e.g.: /add/question
          load_roots_to_session
        end
      end
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

  #
  # Redirects to a given statement
  #
  # Method:   GET
  # Params:   id: integer
  # Response: REDIRECT
  #
  def redirect_to_statement
    options = {}
    %w(origin bids).each{|s| options[s.to_sym] = params[s.to_sym]}
    redirect_to statement_node_url(@statement_node.target_statement, options)
  end

  ##############
  # BREADCRUMB #
  ##############

  #
  # Loads the ancestors' ids
  #
  # Method:   GET
  # Params:   id: integer
  # Response: JSON
  #
  def ancestors
    @statement_ids = @statement_node.self_and_ancestors.map(&:id)
    respond_to do |format|
      format.json{render :json => @statement_ids}
    end
  end

  #############
  # PROTECTED #
  #############

  protected

  #
  # Loads the children of the current statement
  #
  # Loads instance variables:
  # @children(Hash) : key   : class name (String)
  #                   value : an array of statement nodes (Array) or an URL (string)
  # @children_documents(Hash) : key   : statement_id (Integer)
  #                             value : document (StatementDocument)
  #
  def load_all_children
    @children ||= {}
    children_types = @statement_node.class.children_types(:visibility => true).transpose
    if !children_types.empty?
      types = children_types[0]
      @children_documents ||= {}
      types.each_with_index do |type, index|
        immediate_render = children_types[1][index]
        if @children[type].nil?
          if immediate_render
            load_children :type => type
          else
            @children[type] ||= @statement_node.count_child_statements :language_ids => @language_preference_list,
                                                                       :user => current_user,
                                                                       :type => type
          end
        end
      end
    end
  end

  #
  # Loads the children from a certain type of the current statement
  # opts attributes:
  # type (String : optional) : Type of child to load
  #
  # more info about attributes, please check paginated child statements documentation
  #
  # Loads instance variables:
  # @children(Hash) : key   : class name (String)
  #                   value : an array of statement nodes (Array) or an URL (string)
  # @children_documents(Hash) : key   : statement_id (Integer)
  #                             value : document (StatementDocument)
  #
  def load_children(opts)
    opts[:user] ||= current_user
    opts[:language_ids] ||= @language_preference_list
    @children ||= {}
    @children[opts[:type]] = @statement_node.paginated_child_statements(opts)
    @children_documents ||= {}
    @children_documents.merge!(search_statement_documents :statement_ids => @children[opts[:type]].flatten.map(&:statement_id))
  end

  #
  # Load the authors of the current statement.
  #
  # Loads instance variables:
  # @authors(Array[User])
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
  # Loads instance variables:
  # @statement_node(StatementNode)
  #
  def fetch_statement_node
    @statement_node ||= StatementNode.find(params[:id]) if params[:id].try(:any?) && params[:id] =~ /\d+/
  end

  #
  # Gets the type of a new statement.
  #
  # Loads instance variables:
  # @statement_node_type(Class)
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
          format.html { redirect_to statement_node_url @statement_node.parent }
          format.js do
            render :update do |page|
              page.redirect_to statement_node_url @statement_node.parent
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
  # Loads instance variables:
  # @locale_language_id(Integer)
  # @language_preference_list(Array[Integer])
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
  # Loads instance variables:
  # @breadcrumb(Array[]) (check build_breadcrumb documentation)
  # @bids(String) : breadcrumb keycodes separated by comma
  #
  def set_parent_breadcrumb
    return if @statement_node.parent.nil?
    parent_node = @statement_node.parent
    statement_document = search_statement_documents(:statement_ids => [parent_node.statement_id])[parent_node.statement_id] ||
                         parent_node.document_in_original_language
    #[id, classes, url, title, label, over]
    opts = {:key => "fq#{parent_node.id}",
            :css => "statement statement_link #{parent_node.class.name.underscore}_link",
            :url => statement_node_url(parent_node, :bids => params[:bids], :origin => params[:origin]),
            :title => statement_document.title.gsub(/\\;/, ',').gsub(/\\:;/, '|'),
            :label => I18n.t("discuss.statements.breadcrumbs.labels.fq"),
            :over => I18n.t("discuss.statements.breadcrumbs.labels.over.fq")}
    @breadcrumb = build_breadcrumb opts
    @bids = params[:bids]||''
    @bids = @bids.split(",")
    @bids << @breadcrumb[0]
    @bids = @bids.join(",")
  end

  #
  # Sets the breadcrumbs for the current statement node view previous path.
  #
  # Loads instance variables:
  # @breadcrumbs(Array[Array[]]) (check build_breadcrumb documentation)
  #
  def load_breadcrumbs
    return if params[:bids].blank?

    # get bids into an array structure
    bids = params[:bids].split(',')

    @breadcrumbs = []

    bids.each_with_index do |bid, index| #[id, classes, url, title, label, over]
      key = bid[0,2]
      value = CGI.unescape(bid[2..-1])
      opts = {}
      #default values
      opts[:key] = key
      opts[:css] = "search_link statement_link"
      case key
        when "ds" then page_count = value.blank? ? 1 : value[1..-1] # ds|:page_count
                       opts[:url] = discuss_search_url(:page_count => page_count)
                       opts[:title] = I18n.t("discuss.statements.breadcrumbs.discuss_search")
        when "sr" then value = value.split('|')
                       page_count = value.length > 1 ? value[1] : 1 # sr:search_term|:page_count
                       search_terms = value[0].gsub(/\\;/, ',').gsub(/\\:;/, '|')
                       opts[:url] = discuss_search_url(:page_count => page_count, :search_terms => search_terms)
                       opts[:title] = value[0]
        when "mi" then opts[:css] = "my_discussions_link statement_link"
                       opts[:url] = my_questions_url
                       opts[:title] = I18n.t("discuss.statements.breadcrumbs.my_questions")
        when "fq" then statement_node = StatementNode.find(bid[2..-1])
                       statement_document = search_statement_documents(:statement_ids => [statement_node.statement_id])[statement_node.statement_id] ||
                                            statement_node.document_in_original_language
                       origin = index > 0 ? bids[index-1] : ''
                       opts[:key] = "fq#{value}"
                       opts[:css] = "statement statement_link #{statement_node.class.name.underscore}_link"
                       opts[:url] = statement_node_url(statement_node, :bids => bids[0, bids.index(bid)].join(","), :origin => origin)
                       opts[:title] = statement_document.title
      end
      opts[:label] = I18n.t("discuss.statements.breadcrumbs.labels.#{key}")
      opts[:over] = I18n.t("discuss.statements.breadcrumbs.labels.over.#{key}")
      breadcrumb = build_breadcrumb opts
      @breadcrumbs << breadcrumb
    end
  end

  #
  # Sets the breadcrumbs for the current statement node view previous path.
  # opts attributes:
  #
  # key   (String) : breadcrumb identification code
  # css   (String) : css attributes to be inserted into the breadcrumb
  # url   (String) : url path which the breadcrumb will lead to if clicked
  # title (String) : breadcrumb main text
  # label (String) : label that shows up above the title
  # over  (String) : label that replaces the "label" attribute when the "hover" event occurs
  #
  # Returns an array with the attributes above
  #
  def build_breadcrumb(opts={})
    [opts[:key],opts[:css],opts[:url],opts[:title], opts[:label], opts[:over]]
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

  
  ##########
  # SEARCH #
  ##########

  #
  # Calls the statement node sql query for questions.
  # opts attributes:
  #
  # search_term (String : optional) : text snippet to look for in the statements
  #
  # for more info about attributes, please check the StatementNode.search_discussions documentation
  #
  def search_discussions(opts = {})
    languages = @language_preference_list
    if opts[:node] and !opts[:node].new_record?
      # VERY IMP: remove statement original language if user doesn't speak it
      original_language = opts[:node].original_language
      languages -= [original_language.id] if languages.length > 1 and original_language.code.to_s != I18n.locale and 
                                             (current_user.nil? or 
                                              !current_user.sorted_spoken_languages.include?(original_language.id)) 
    end
    StatementNode.search_discussions(opts.merge({:user => current_user,
                                                 :language_ids => languages,
                                                 :show_unpublished => current_user && current_user.has_role?(:editor)}))
  end

  #
  # Gets all the statement documents belonging to a group of statements, and orders them per language ids.
  # opts attributes:
  #
  # statement_ids (Array[Integer]) : ids from statements which documents we should look through
  # for more info about attributes, please check the StatementDocument.search_statement_documents documentation
  #
  def search_statement_documents(opts={})
    opts[:language_ids] ||= @language_preference_list
    l_ids = opts[:language_ids]
    statement_documents = StatementDocument.search_statement_documents(opts).sort! {|a, b|
      l_ids.index(a.language_id) <=> l_ids.index(b.language_id)
    }
    statement_documents.each_with_object({}) do |sd, documents_hash|
      documents_hash[sd.statement_id] = sd unless documents_hash.has_key?(sd.statement_id)
    end
  end





  ############################
  # SESSION HANDLING HELPERS #
  ############################

  #
  # Loads information necessary to build a breadcrumb for the new Follow Up Statement
  #
  # Loads instance variables:
  # @previous_node(StatementNode) : the parent of the new statement
  # @previous_type(String) : type of breadcrumb
  #
  def load_origin_statement
    @previous_node = @statement_node.parent
    @previous_type = case @statement_node.class.name
      when "FollowUpQuestion" then "fq"
    end
  end


  #
  # Loads the ancestors of the current statement node, in order to display the correct context.
  # On the process, loads its siblings (check load_siblings, load_roots_to_session and load_children_for_parent documentation)
  #
  # teaser(Boolean) : if true, @statement_node is the PARENT node of the teaser.
  #
  # Loads instance variables:
  # @ancestors(Array[StatementNode]) : ancestors of the current statement node
  # @ancestor_documents(Hash) : key   : statement id (Integer)
  #                             value : document (StatementDocument)
  #                             documents belonging to the loaded ancestors
  #
  def load_ancestors(teaser = false)
    if @statement_node
      @ancestors = @statement_node.ancestors
      @ancestor_documents = {}
      @ancestors.each {|a| load_siblings(a) }

      load_siblings(@statement_node) # if teaser: @statement_node is the teaser's parent, otherwise the node on the bottom-most level
      if teaser
        @ancestors << @statement_node # if teaser: @statement_node is the teaser's parent, therefore, an ancestor
        load_children_for_parent(@statement_node, @type)
      end

      @ancestors.each{|a|@ancestor_documents[a.statement_id] = a.document_in_preferred_language(@language_preference_list)}
    else
      if teaser
        load_roots_to_session
      else
        @ancestors = []
      end
    end
  end

  #
  # Loads the children ids array formatted for session from a certain type of a certain statement node
  #
  # statement_node(StatementNode) : the parent node
  # type(String)                  : the type of children we want to get
  #
  # Loads instance variables:
  # @siblings(Hash) : key   : statement node dom id ; ":type_:id" or "add_:type" for teasers (String)
  #                   value : Array[Integer] : Array of statement ids with teaser path as last element
  #
  def load_children_for_parent(statement_node, type)
    @siblings ||= {}
    class_name = type.classify
    siblings = statement_node.children_to_session :language_ids => @language_preference_list,
                                                  :type => class_name, :user => current_user
    @siblings["add_#{type}"] = siblings
  end

  #
  # Loads siblings of a statement node.
  #
  # statement_node(StatementNode) : the statement node
  #
  # Loads instance variables:
  # @siblings(Hash) : key   : statement node dom id ; ":type_:id" or "add_:type" for teasers (String)
  #                   value : Array[Integer] : Array of statement ids with teaser path as last element
  #
  def load_siblings(statement_node)
    @siblings ||= {}
    class_name = statement_node.target_statement.class.name.underscore
    # if has parent then load siblings
    if statement_node.parent_id
      siblings = statement_node.siblings_to_session :language_ids => @language_preference_list, :user => current_user
    else #else, it's a root node
      siblings = roots_to_session(statement_node)
    end
    @siblings["#{class_name}_#{statement_node.target_id}"] = siblings
  end

  #
  # Loads Add Question Teaser siblings (Only for HTTP and add question teaser).
  #
  # Loads instance variables:
  # @siblings(Hash) : key   : statement node dom id ; ":type_:id" or "add_:type" for teasers (String)
  #                   value : Array[Integer] : Array of statement ids with teaser path as last element
  #
  def load_roots_to_session
    @siblings ||= {}
    @siblings["add_question"] = roots_to_session
  end

  #
  # Gets the root ids that need to be loaded to the session.
  #
  # statement_node(StatementNode : optional) : statement node which is currently shown
  #
  def roots_to_session(statement_node=nil)
    load_roots :node => statement_node, :per_page => -1, :for_session => true
  end


  #
  # Loads The Roots for current Top Statement (Question, Follow Up Question, ...)
  # opts attributes:
  #
  # node (StatementNode : optional) : statement node which is currently shown
  # page (Integer : optional) : pagination parameter (default = 1)
  # per_page (Integer : optional) : pagination parameter (default = QUESTIONS_PER_PAGE)
  #
  # Loads instance variables (if not for session):
  # @children(Hash) : key   : class name (String)
  #                   value : an array of statement nodes (Array) or an URL (string)
  # @children_documents(Hash) : key   : statement_id (Integer)
  #                             value : document (StatementDocument)
  #
  def load_roots(opts)
    opts[:page] ||= 1
    opts[:per_page] ||= QUESTIONS_PER_PAGE
    opts[:for_session] ||= false
    if !params[:origin].blank? #statement node is a question
      origin = params[:origin]
      key = origin[0,2]
      value = CGI.unescape(origin[2..-1])
      roots = case key
       # get question siblings depending from the request's origin (key)
       # discuss search with no search results
       when 'ds' then per_page = value.blank? ? QUESTIONS_PER_PAGE : value[1..-1].to_i * QUESTIONS_PER_PAGE
                      sn = search_discussions(:only_id => opts[:for_session], :node => opts[:node]).paginate(:page => 1, :per_page => per_page)
                      opts[:for_session] ? sn.map(&:root_id) + ["/add/question"] : sn
       # discuss search with search results
     when 'sr'then value = value.split('|')
                   term = value[0].gsub(/\\;/,',').gsub(/\\:;/, '|')
                   per_page = value.length > 1 ? value[1].to_i * QUESTIONS_PER_PAGE : QUESTIONS_PER_PAGE
                   sn = search_discussions(:search_term => term,
                                           :only_id => opts[:for_session], :node => opts[:node]).paginate(:page => 1, :per_page => per_page)
                   opts[:for_session] ? sn.map(&:root_id) + ["/add/question"] : sn
       # my discussions
       when 'mi' then sn = Question.by_creator(current_user).by_creation
                      opts[:for_session] ? sn.only_id.map(&:id) + ["/add/question"] : sn
       # follow up questions from a statement
       when 'fq' then @previous_node = StatementNode.find(value)
                      @previous_type = "FollowUpQuestion"
                      sn = @previous_node.child_statements :language_ids => @language_preference_list,
                                                           :type => @previous_type,
                                                           :user => current_user,
                                                           :for_session => opts[:for_session]
                      opts[:for_session] ? sn : sn.map(&:target_statement)
      end
    else
      # no origin (direct link)
      roots = opts[:node].nil? ? [] : [opts[:node]]
      roots = roots.map(&:id) + ["/add/question"] if opts[:for_session]
    end
    if !opts[:for_session] # for descendants, must load statement documents and fill the necessary attributes for rendering
      per_page = opts[:per_page].to_i == -1 ? roots.length : opts[:per_page].to_i
      per_page = 1 if per_page == 0 # in case roots is an empty array
      @children = {}
      type = opts[:node].nil? ? @type : opts[:node].class.name 
      @children[type.to_sym] = roots.paginate :page => opts[:page].to_i, :per_page => per_page

      @children_documents = search_statement_documents :statement_ids => @children[type.to_sym].flatten.map(&:statement_id)
    end
    roots
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
    return if !origin[0,2].eql?('sr')
    origin = CGI.unescape(origin).split('|')[0]
    default_tags = origin[2..-1].gsub(/\\;/, ',').gsub(/\\:;/, '|')
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
