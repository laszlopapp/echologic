class StatementNode < ActiveRecord::Base
  acts_as_extaggable :topics
  acts_as_echoable
  acts_as_subscribeable
  acts_as_nested_set :scope => :root_id


  alias_attribute :target_id, :id

  def target_statement
    self
  end

  after_destroy :destroy_statement

  def destroy_statement
    self.statement.destroy if (self.statement.statement_nodes - [self]).empty?
  end

  ##
  ## ASSOCIATIONS
  ##

  belongs_to :creator, :class_name => "User"
  belongs_to :statement

  delegate :original_language, :document_in_language, :authors, :has_author?,
           :statement_image, :statement_image=, :image, :image=, :to => :statement

  has_enumerated :editorial_state, :class_name => 'StatementState'

  has_many :statement_documents, :through => :statement, :source => :statement_documents do
    def for_languages(lang_ids)
      find(:all,
           :conditions => {:language_id => lang_ids, :current => true},
           :order => 'created_at ASC').sort {|a, b|
        lang_ids.index(a.language_id) <=> lang_ids.index(b.language_id)
      }.first
    end
  end

  ##
  ## VALIDATIONS
  ##

  validates_presence_of :editorial_state_id
  validates_numericality_of :editorial_state_id
  validates_presence_of :creator_id
  validates_presence_of :statement
  validates_associated :creator
  validates_associated :statement

  ##
  ## NAMED SCOPES
  ##

  #auxiliar named scopes only used for tests
  %w(question proposal improvement pro_argument contra_argument follow_up_question).each do |type|
    class_eval %(
      named_scope :#{type.pluralize}, lambda{{ :conditions => { :type => '#{type.camelize}' } } }
    )
  end
  named_scope :published, lambda {|auth|
    { :conditions => { :editorial_state_id => StatementState['published'].id } } unless auth }
  named_scope :by_creator, lambda {|id|
  {:conditions => ["creator_id = ?", id]}}

  # orders
  named_scope :by_ratio, :include => :echo, :order => '(echos.supporter_count/echos.visitor_count) DESC'
  named_scope :by_supporters, :include => :echo, :order => 'echos.supporter_count DESC'
  named_scope :by_creation, :order => 'created_at DESC'
  named_scope :only_id, :select => 'statement_nodes.id'


  ## ACCESSORS
  %w(title text).each do |accessor|
    class_eval %(
      def #{accessor}(lang_ids)
        doc = statement_documents.for_languages(lang_ids)
        doc ? statement_documents.for_languages(lang_ids).#{accessor} : raise('no #{accessor} found in this language')
      end
    )
  end

  ##############################
  ######### ACTIONS ############
  ##############################

  def publishable?
    false
  end

  # static for now
  def published?
    self.editorial_state == StatementState["published"]
  end

  # Publish a statement.
  def publish
    self.editorial_state = StatementState["published"]
  end
  
  
  # Initializes this statement node's statement
  def set_statement(attrs)
    self.statement = Statement.new(attrs)
  end

  # creates a new statement_document
  def add_statement_document(attributes={ },opts={})
    if self.statement.nil?
      original_language_id = attributes.delete(:original_language_id).to_i
      set_statement(:original_language_id => original_language_id)
    end
    doc = StatementDocument.new
    doc.statement = self.statement
    attributes.each {|k,v|doc.send("#{k.to_s}=", v)}
    self.statement.statement_documents << doc
    return doc
  end

  ########################
  # DOCUMENTS' LANGUAGES #
  ########################

  #
  # Checks if there is a document in any of the languages passed as argument
  #
  def translated_document?(lang_ids)
    return statement_documents.for_languages(lang_ids).nil?
  end

  #
  # returns a translated document for passed language_codes (or nil if none is found)
  #
  def document_in_preferred_language(lang_ids)
    @current_document ||= statement_documents.for_languages(lang_ids)
  end


  #
  # Checks if there is no document written in the given language code and that the current user has the
  # required language skills to translate it (speaks both languages at least intermediate).
  #
  def translatable?(user, from_language, to_language)
    if user && from_language != to_language
      languages = user.spoken_languages_at_min_level('advanced')
      languages.include?(from_language) && languages.include?(to_language)
    else
      false
    end
  end

  # Checks if, in case the user hasn't yet set his language knowledge, the current language is different from
  # the statement original language. used for the original message warning
  def not_original_language?(user, current_language_id)
    user ? (user.spoken_languages.empty? and current_language_id != original_language.id) : false
  end

  #
  # Returns the current document in its original language.
  #
  def document_in_original_language
    document_in_language(original_language)
  end

  #####################
  # CHILDREN/SIBLINGS #
  #####################

  # Collects a filtered list of all children statements
  #
  # for_session argument: when true, returns a list of ids + the "add_type" teaser name
  def child_statements(language_ids = nil, type = self.class.children_types.first.to_s, for_session = false)
    return type.constantize.statements_for_parent(self.target_id, language_ids, self.draftable?, for_session)
  end
  
  # Collects a filtered list of all siblings statements
  #
  # for_session argument: when true, returns a list of ids + the "add_type" teaser name
  def sibling_statements(language_ids = nil, type = self.class.to_s, for_session = false)
    return parent_id.nil? ? [] : type.constantize.statements_for_parent(self.parent.target_id, language_ids, self.incorporable?, for_session)
  end

  # Collects a filtered list of all siblings statements
  def siblings_to_session(language_ids = nil, type = self.class.to_s)
    sibling_statements(language_ids, type, true)
  end

  # Collects a filtered list of all siblings statements
  def children_to_session(language_ids = nil, type = self.class.children_types.first.to_s)
    child_statements(language_ids, type, true)
  end

  # Get the top children given a certain child type
  def get_paginated_child_statements(language_ids = nil,
                                     type = self.class.children_types.first.to_s,
                                     page = 1,
                                     per_page = TOP_CHILDREN)
    type_class = type.constantize
    children = child_statements(language_ids, type)
    type_class.paginate_statements(children, page, per_page)
  end
 
  private

  #################
  # Class methods #
  #################

  class << self

    # Aux Function: generates new instance (overwritten in follow up question)
    def new_instance(attributes = nil)
      self.new(attributes)
    end

    # Aux Function: GUI Helper (overwritten in follow up question)
    def is_top_statement?
      false
    end

    # Aux Function: paginates a set of ActiveRecord Objects
    def paginate_statements(children, page, per_page)
      children.paginate(default_scope.merge(:page => page, :per_page => per_page))
    end

    # Aux Function: gets a set of children given a certain parent (used to get siblings and children)
    def statements_for_parent(parent_id, language_ids = nil, filter_drafting_state = false, for_session = false)
      do_statements_for_parent(parent_id, language_ids, filter_drafting_state, for_session)
    end
    
    # Aux Function: gets a set of children given a certain parent (used above)
    def do_statements_for_parent(parent_id, language_ids = nil, filter_drafting_state = false, for_session = false)
      opts = {}
      opts[:readonly] = false
      opts[:joins] =  "LEFT JOIN statement_documents d    ON statement_nodes.statement_id = d.statement_id "
      opts[:joins] << "LEFT JOIN echos e                  ON statement_nodes.echo_id = e.id"
      opts[:conditions] = children_conditions(parent_id)
      opts[:conditions] << sanitize_sql([" and d.language_id IN (?) ", language_ids]) if language_ids
      opts[:conditions] << drafting_conditions if filter_drafting_state
      opts[:order] = "e.supporter_count DESC, statement_nodes.created_at DESC"
      statements = []
      
      if for_session
        opts[:select] = "DISTINCT statement_nodes.id, statement_nodes.question_id"
        statements = self.scoped(opts).map{|s| s.question_id.nil? ? s.id : s.question_id}
        statements << "/#{parent_id.nil? ? '' : "#{parent_id}/" }add/#{self.name.underscore}"
      else
        opts[:select] = "DISTINCT statement_nodes.*"
        statements = self.scoped(opts)
      end
      statements
    end

    # Aux Function: drafting conditions on a query (overwritten in acts_as_incorporable)
    def drafting_conditions
      ''
    end
    
    def children_conditions(parent_id)
      sanitize_sql(["statement_nodes.type = ? AND statement_nodes.parent_id = ? ", self.name, parent_id])
    end

    public


    # gets a set of statement nodes given an hash of arguments
    def search_statement_nodes(opts={})
      search_term = opts.delete(:search_term)
      if (!search_term.blank?)
        tag_clause = "SELECT DISTINCT s.* FROM statement_nodes s 
          LEFT JOIN tao_tags tt                 ON (tt.tao_id = s.id and tt.tao_type = 'StatementNode')
          LEFT JOIN statement_documents d       ON s.statement_id = d.statement_id
          LEFT JOIN tags t                      ON tt.tag_id = t.id
          LEFT JOIN echos e                     ON s.echo_id = e.id
          WHERE 
        "
        
        tags_query = ''
        if !search_term.blank?
          tags_query = []
          terms = search_term.split(/[,\s]+/)
          terms.each do |term|
            clause = tag_clause + sanitize_sql(["(t.value LIKE ? OR t.value = ?)", "%#{term}%", term])
            clause << sanitize_sql([" AND d.language_id IN (?)", opts.delete(:language_ids)]) if opts[:language_ids]
            tags_query << clause
          end
          
        end
        tags_query = tags_query.join(" UNION ALL ")
        tags_query = "SELECT nodes_by_tag_count.*, COUNT(nodes_by_tag_count.id) count FROM (#{tags_query}) nodes_by_tag_count " +
                     "LEFT JOIN echos e               ON nodes_by_tag_count.echo_id = e.id" + 
                     " GROUP BY nodes_by_tag_count.id order by count DESC, e.supporter_count DESC, nodes_by_tag_count.created_at ASC;"
        
        statement_nodes_by_tags = find_by_sql tags_query
      else
        statement_nodes_by_tags = []
      end
      title_text_query = "SELECT DISTINCT  s.* FROM statement_nodes s
        LEFT JOIN statement_documents d       ON s.statement_id = d.statement_id
        LEFT JOIN echos e                     ON s.echo_id = e.id
        WHERE "
      title_text_conditions = []
      title_text_conditions << sanitize_sql(["(d.title LIKE ? OR d.text = ?)", "%#{search_term}%", search_term]) if !search_term.blank?
      title_text_conditions << sanitize_sql(["s.type = '#{opts.delete(:type)}'"]) if opts[:type]
      title_text_conditions << sanitize_sql(["s.id NOT IN (?)", statement_nodes_by_tags.map(&:id)]) if !statement_nodes_by_tags.empty?
      title_text_conditions << sanitize_sql(["s.editorial_state_id = ?", StatementState['published'].id]) unless opts.delete(:show_unpublished)
      title_text_conditions << sanitize_sql(["d.language_id IN (?)", opts.delete(:language_ids)]) if opts[:language_ids]
      title_text_conditions << sanitize_sql(["s.drafting_state IN (?)", opts.delete(:drafting_states)]) if opts[:drafting_states]
      
      title_text_query << title_text_conditions.join(" AND ")
      
      title_text_query << " ORDER BY e.supporter_count DESC, s.created_at ASC;"
      
      statement_nodes_by_title_and_text = find_by_sql title_text_query
      
      statement_nodes_by_title_and_text + statement_nodes_by_tags
      
#      opts[:readonly] = false
#      opts[:select] ||= "DISTINCT statement_nodes.*"
#
#      # join clauses
#      opts[:joins] =  "LEFT JOIN statement_documents d       ON statement_nodes.statement_id = d.statement_id "
#      opts[:joins] << "LEFT JOIN tao_tags tt                 ON (tt.tao_id = statement_nodes.id and tt.tao_type = 'StatementNode') "
#      opts[:joins] << "LEFT JOIN tags t                      ON tt.tag_id = t.id "
#      opts[:joins] << "LEFT JOIN echos e                     ON statement_nodes.echo_id = e.id"
#
#
#      opts[:conditions] ||= []
#      
#      # building the where clause
#      
#      or_conditions = ""
#      search_term = opts.delete(:search_term)
#      if !search_term.blank?
#        terms = search_term.split(/[,\s]+/)
#        or_conditions << %w(d.title d.text).map{|attr|sanitize_sql(["#{attr} LIKE ?", "%#{search_term}%"])}.join(" OR ")
#        or_conditions << " OR #{terms.map{|term| term.length > 3 ? sanitize_sql(["t.value LIKE ?","%#{term}%"]) :
#                                                                   sanitize_sql(["t.value = ?",term])}.join(" OR ")}"
#      end
#      
#      
#      # Filter for statement type
#      opts[:conditions] << "statement_nodes.type = '#{opts.delete(:type)}'" if opts[:type]
#      opts[:conditions] << sanitize_sql(["statement_nodes.editorial_state_id = ?", StatementState['published'].id]) unless opts.delete(:show_unpublished)
#      opts[:conditions] << sanitize_sql(["d.language_id IN (?)", opts.delete(:language_ids)]) if opts[:language_ids]
#      opts[:conditions] << sanitize_sql(["statement_nodes.drafting_state IN (?)", opts.delete(:drafting_states)]) if opts[:drafting_states]
#      # Constructing the where clause
#      opts[:conditions] << "(#{or_conditions})" if !or_conditions.blank?
#      opts[:conditions] = opts[:conditions].join(" AND ")
#      
#      # Building the order clause
#      opts[:order] ||= "e.supporter_count DESC, statement_nodes.created_at DESC"
#      
#      scoped opts
    end


    def default_scope
      { :include => :echo,
        :order => %Q[echos.supporter_count DESC, statement_nodes.created_at ASC] }
    end

    ###################################
    # EXPANDABLE CHILDREN GUI HELPERS #
    ###################################

    # 
    # visibility = false: returns an array of symbols of the possible children types
    # visibility = true: returns an array of sub arrays representing pairs [type: symbol class , visibility : true/false]
    # default: whether we should take out from or let the default children types in the array
    # expand: whether we should replace a children type for it's sub-types
    #
    def children_types(visibility = false, default = true, expand = false)
      children_types = @@children_types[self.name] || @@children_types[self.superclass.name]
      children_types = children_types - @@default_children_types if !default
      if expand
        array = []
        children_types.each{|c| array += c[0].to_s.constantize.sub_types.map{|st|[st, c[1]]} }
        children_types = array
      end
      return children_types.map{|c|c[0]} if !visibility
      children_types
    end

    
    # PARTIAL PATHS #
    def children_list_template
      "statements/children_list"
    end

    def children_template
      "statements/children"
    end

    def more_template
      "statements/more"
    end

    #protected

    def sub_types
      [self.name.to_sym]
    end

    def default_children_types(*klasses)
      @@default_children_types = klasses
    end

    def has_children_of_types(*klasses)
      @@children_types ||= { }
      @@children_types[self.name] ||= @@default_children_types.nil? ? [] : @@default_children_types
      @@children_types[self.name] = klasses + @@children_types[self.name]
    end
  end
  default_children_types [:FollowUpQuestion,true]
end
