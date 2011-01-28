class StatementNode < ActiveRecord::Base
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
           :statement_image, :statement_image=, :image, :image=, :published?, :publish,
           :taggable?, :topic_tags, :topic_tags=, :tags, :editorial_state_id, :editorial_state_id=,
           :editorial_state, :editorial_state=, :to => :statement

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

  named_scope :by_creator, lambda {|id|
  {:conditions => ["creator_id = ?", id]}}
  named_scope :published, lambda {|auth|
  {:joins => :statement, :conditions => ["statements.editorial_state_id = ?", StatementState['published'].id] } unless auth }

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



  # Initializes this statement node's statement
  def set_statement(attrs={})
    self.statement = Statement.new(attrs)
  end

  # creates a new statement_document
  def add_statement_document(attributes={ },opts={})
    self.set_statement if self.statement.nil?
    self.statement.original_language_id = attributes.delete(:original_language_id).to_i if attributes[:original_language_id]
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
    def new_instance(attributes = {})
      attributes[:editorial_state] = StatementState[attributes.delete(:editorial_state_id).to_i] if attributes[:editorial_state_id]
      editorial_state = attributes.delete(:editorial_state)
      node = self.new(attributes)
      node.set_statement(:editorial_state => editorial_state)
      node
    end

    # Aux Function: GUI Helper (overwritten in follow up question)
    def is_top_statement?
      false
    end

    # Aux Function: Get Siblings Helper (overwritten in doubles)
    def name_for_siblings
      self.name.underscore
    end

    # Aux Function: paginates a set of ActiveRecord Objects
    def paginate_statements(children, page, per_page = nil)
      per_page = children.length if per_page.nil? or per_page < 0
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
        statements = self.all(opts)
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
      opts[:only_id] ||= false
      tag_clause = "SELECT DISTINCT s.id FROM statement_nodes s "
      tag_clause << "LEFT JOIN statements st               ON st.id = s.statement_id
                     LEFT JOIN tao_tags tt                 ON (tt.tao_id = st.id and tt.tao_type = 'Statement')
                     LEFT JOIN statement_documents d       ON s.statement_id = d.statement_id
                     LEFT JOIN tags t                      ON tt.tag_id = t.id "
      tag_clause << "WHERE "


      tags_query = ''
      and_conditions = []
      and_conditions << sanitize_sql(["s.type = '#{opts.delete(:type)}'"]) if opts[:type]
      and_conditions << sanitize_sql(["st.editorial_state_id = ?", StatementState['published'].id]) unless opts[:show_unpublished]
      and_conditions << sanitize_sql(["d.language_id IN (?)", opts[:language_ids]]) if opts[:language_ids]
      and_conditions << sanitize_sql(["s.drafting_state IN (?)", opts[:drafting_states]]) if opts[:drafting_states]
      if !search_term.blank?
        tags_query = []
        terms = search_term.split(/[,\s]+/)
        terms.each do |term|
          or_conditions = (term.length > 3 ? sanitize_sql(["t.value LIKE ?","%#{term}%"]) : sanitize_sql(["t.value = ?",term]))
          or_conditions << sanitize_sql([" OR d.title LIKE ? OR d.text LIKE ?", "%#{term}%", "%#{term}%"])
          tags_query << (tag_clause + (and_conditions + ["(#{or_conditions})"]).join(" AND "))
        end
        tags_query = tags_query.join(" UNION ALL ")
        statements_query = "SELECT statement_nodes.#{opts[:only_id] ? 'id' : '*'} " +
                           "FROM (#{tags_query}) statement_node_ids " +
                           "LEFT JOIN statement_nodes ON statement_nodes.id = statement_node_ids.id " +
                           "LEFT JOIN echos e ON e.id = statement_nodes.echo_id " +
                           "GROUP BY statement_node_ids.id " +
                           "ORDER BY COUNT(statement_node_ids.id) DESC,e.supporter_count DESC, statement_nodes.created_at DESC;"
      else
        statements_query = "SELECT DISTINCT s.#{opts[:only_id] ? 'id' : '*'} from statement_nodes s
                            LEFT JOIN statements st ON st.id = s.statement_id
                            LEFT JOIN statement_documents d ON s.statement_id = d.statement_id
                            LEFT JOIN echos e ON e.id = s.echo_id
                            WHERE " + and_conditions.join(" AND ") +
                           " ORDER BY e.supporter_count DESC, s.created_at DESC;"
      end
      find_by_sql statements_query
    end


    def default_scope
      { :include => :echo,
        :order => %Q[echos.supporter_count DESC, statement_nodes.created_at DESC] }
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

    def descendants_template
      "statements/descendants"
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
