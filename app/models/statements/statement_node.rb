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
           :taggable?, :filtered_topic_tags, :topic_tags, :topic_tags=, :hash_topic_tags, :tags, :editorial_state_id,
           :editorial_state_id=, :editorial_state, :editorial_state=, :to => :statement

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

  named_scope :by_creator, lambda {|id| {:conditions => ["creator_id = ?", id]}}
  named_scope :published, lambda {|auth|
    {:joins => :statement, :conditions => ["statements.editorial_state_id = ?", StatementState['published'].id] } unless auth
  }

  # orders
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
  def child_statements(opts={})
    opts[:parent_id] = self.target_id
    opts[:filter_drafting_state] = self.draftable?
    opts[:type] ||= self.class.children_types.first.to_s
    return opts[:type].constantize.statements_for_parent(opts)
  end

  # Collects a filtered list of all siblings statements
  #
  # for_session argument: when true, returns a list of ids + the "add_type" teaser name
  def sibling_statements(opts={})
    opts[:parent_id] = self.parent.target_id
    opts[:filter_drafting_state] = self.incorporable?
    opts[:type] ||= self.class.to_s
    return opts[:parent_id].nil? ? [] : opts[:type].constantize.statements_for_parent(opts)
  end

  # Collects a filtered list of all siblings statements
  def siblings_to_session(opts)
    opts[:type] ||= self.class.to_s
    opts[:for_session] = true
    sibling_statements(opts)
  end

  # Collects a filtered list of all siblings statements
  def children_to_session(opts)
    opts[:type] ||= self.class.children_types.first.to_s
    opts[:for_session] = true
    child_statements(opts)
  end

  # Get the top children given a certain child type
  def paginated_child_statements(opts)
    opts[:type] ||= self.class.children_types.first.to_s
    opts[:page] ||= 1
    opts[:per_page] ||= TOP_CHILDREN
    children = child_statements(opts)
    opts[:type].constantize.paginate_statements(children, opts[:page], opts[:per_page])
  end

  # counts the children the statement has of a certain type
  def count_child_statements(opts)
    opts[:parent_id] = self.target_id
    opts[:filter_drafting_state] = self.draftable?
    opts[:type] ||= self.class.children_types.first.to_s
    opts[:type].constantize.count_statements_for_parent(opts)
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

    ################################
    # CHILDREN BLOCK QUERY HELPERS #
    ################################

    #
    # Aux Function: gets a set of children given a certain parent (used to get siblings and children)
    #
    def statements_for_parent(opts)
      get_statements_for_parent(opts)
    end

    #
    # Aux Function: gets a set of children given a certain parent (used above)
    #
    def get_statements_for_parent(opts)
      fields = parent_conditions(opts)

      statements = []

      if opts[:for_session]
        fields[:select] = "DISTINCT #{table_name}.id, #{table_name}.question_id"
        statements = self.scoped(fields).map{|s| s.question_id.nil? ? s.id : s.question_id}
        statements << "/#{opts[:parent_id].nil? ? '' : "#{opts[:parent_id]}/" }add/#{self.name.underscore}" # ADD TEASER
      else
        fields[:select] = "DISTINCT #{table_name}.*"
        statements = self.all(fields)
      end
      statements
    end

    #
    # Returns the number of child statements of a certain type (or types) from a given statement
    #
    def count_statements_for_parent(opts)
      fields = parent_conditions(opts.merge({:types => sub_types.map(&:to_s)}))
      fields[:select] = "DISTINCT #{table_name}.id"
      self.count(:all, fields)
    end

    #
    # Aux: Builds the query attributes for the children operations
    #
    def parent_conditions(opts)
      fields = {}
      fields.delete(:readonly)
      fields[:joins] =  "LEFT JOIN #{StatementDocument.table_name} d ON #{table_name}.statement_id = d.statement_id "
      fields[:joins] << "LEFT JOIN #{Echo.table_name} e ON #{table_name}.echo_id = e.id"
      fields[:joins] << children_joins
      fields[:conditions] = children_conditions(opts)
      fields[:conditions] << sanitize_sql([" AND d.language_id IN (?) ", opts[:language_ids]]) if opts[:language_ids]
      fields[:conditions] << drafting_conditions if opts[:filter_drafting_state]
      fields[:order] = "e.supporter_count DESC, #{table_name}.created_at DESC"
      fields
    end

    def children_joins
      ''
    end

    def children_conditions(opts)
      sanitize_sql(["#{table_name}.type IN (?) AND #{table_name}.parent_id = ? ",
                    opts[:types] || [self.name], opts[:parent_id]])
    end

    public


    # gets a set of statement nodes given an hash of arguments
    def search_statement_nodes(opts={})
      search_term = opts.delete(:search_term)
      opts[:only_id] ||= false
      tag_clause = "SELECT DISTINCT s.id FROM #{table_name} s "
      tag_clause << "LEFT JOIN #{Statement.table_name}               ON #{Statement.table_name}.id = s.statement_id " +
                    "LEFT JOIN #{StatementDocument.table_name} d        ON s.statement_id = d.statement_id "
      tag_clause << Statement.extaggable_joins_clause
      tag_clause << "WHERE "


      tags_query = ''
      and_conditions = []
      and_conditions << sanitize_sql(["s.type = '#{opts.delete(:type)}'"]) if opts[:type]
      unless opts[:show_unpublished]
        publish_condition = []
        publish_condition << sanitize_sql(["#{Statement.table_name}.editorial_state_id = ?",StatementState['published'].id])
        publish_condition << sanitize_sql(["s.creator_id = ?",  opts[:user].id]) if opts[:user]
        and_conditions << "(#{publish_condition.join(' OR ')})"
      end
      and_conditions << sanitize_sql(["d.language_id IN (?)", opts[:language_ids]]) if opts[:language_ids]
      and_conditions << sanitize_sql(["s.drafting_state IN (?)", opts[:drafting_states]]) if opts[:drafting_states]
      if !search_term.blank?
        tags_query = []
        terms = search_term.split(/[,\s]+/)
        terms.each do |term|
          or_conditions = Statement.extaggable_conditions_for_term(term)
          or_conditions << sanitize_sql([" OR d.title LIKE ? OR d.text LIKE ?", "%#{term}%", "%#{term}%"])
          tags_query << (tag_clause + (and_conditions + ["(#{or_conditions})"]).join(" AND "))
        end
        tags_query = tags_query.join(" UNION ALL ")
        statements_query = "SELECT #{table_name}.#{opts[:only_id] ? 'id' : '*'} " +
                           "FROM (#{tags_query}) statement_node_ids " +
                           "LEFT JOIN #{table_name} ON #{table_name}.id = statement_node_ids.id " +
                           "LEFT JOIN #{Echo.table_name} e ON e.id = #{table_name}.echo_id " +
                           "GROUP BY statement_node_ids.id " +
                           "ORDER BY COUNT(statement_node_ids.id) DESC,e.supporter_count DESC, #{table_name}.created_at DESC;"
      else
        statements_query = "SELECT DISTINCT s.#{opts[:only_id] ? 'id' : '*'} from #{table_name} s " +
                           "LEFT JOIN #{Statement.table_name} ON #{Statement.table_name}.id = s.statement_id " +
                           "LEFT JOIN #{StatementDocument.table_name} d ON s.statement_id = d.statement_id " +
                           "LEFT JOIN #{Echo.table_name} e ON e.id = s.echo_id " +
                           "WHERE " + and_conditions.join(' AND ') + 
                           " ORDER BY e.supporter_count DESC, s.created_at DESC;"
      end
      find_by_sql statements_query
    end


    def default_scope
      { :include => :echo,
        :order => "echos.supporter_count DESC, #{table_name}.created_at DESC" }
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
    def children_types(opts={})
      types = @@children_types[self.name] || @@children_types[self.superclass.name]
      types -= @@default_children_types if opts[:no_default]
      if opts[:expand]
        array = []
        types.each{|c| array += c[0].to_s.constantize.sub_types.map{|st|[st, c[1]]} }
        types = array
      end
      return types.map{|c|c[0]} if !opts[:visibility]
      types
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
