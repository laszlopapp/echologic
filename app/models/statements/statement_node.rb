class StatementNode < ActiveRecord::Base
  acts_as_extaggable :topics
  acts_as_echoable
  acts_as_subscribeable
  acts_as_nested_set #:scope => :root_id

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
  %w(question proposal improvement_proposal pro_argument contra_argument follow_up_question).each do |type|
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

  # returns a translated document for passed language_codes (or nil if none is found)
  def document_in_preferred_language(lang_ids)
    @current_document ||= statement_documents.for_languages(lang_ids)
  end

  def translated_document?(lang_ids)
    return statement_documents.for_languages(lang_ids).nil?
  end

  # creates a new statement_document
  def add_statement_document(attributes={ },opts={})
    if self.statement.nil?
      original_language_id = attributes.delete(:original_language_id).to_i
      self.statement = Statement.new(:original_language_id => original_language_id)
    end
    doc = StatementDocument.new
    doc.statement = self.statement
    attributes.each {|k,v|doc.send("#{k.to_s}=", v)}
    self.statement.statement_documents << doc
    return doc
  end

  # creates and saves a  statement_document with given parameters a
#  def add_statement_document!(*args)
#    original_language_id = args[0].delete(:original_language_id)
#    self.statement = Statement.new(:original_language_id => original_language_id) if self.statement_id.nil?
#    doc = StatementDocument.new(:statement_id => self.statement.id)
#    doc.statement = self.statement
#    doc.update_attributes!(*args)
#    self.statement.statement_documents << doc
#    return doc
#  end


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

  # Collects a filtered list of all children statements
  #
  # for_session argument: when true, returns a list of ids + the "add_type" teaser name
  def child_statements(language_ids = nil, type = self.class.children_types.first.to_s, for_session = false)
    return type.constantize.statements_for_parent(self.id_as_parent, language_ids, self.draftable?, for_session)
  end

  # Collects a filtered list of all siblings statements
  def sibling_statements(language_ids = nil, type = self.class.to_s)
    return parent_id.nil? ? [] : type.constantize.statements_for_parent(self.parent.id_as_parent, language_ids, self.incorporable?)
  end

  # Collects a filtered list of all siblings statements
  def siblings_to_session(language_ids = nil, type = self.class.to_s)
    sibling_statements(language_ids, type).map(&:id) + ["#{self.parent_id ? "/#{self.parent.id_as_parent}" : ''}/add/#{type.underscore}"]
  end

  # Collects a filtered list of all siblings statements
  def children_to_session(language_ids = nil, type = self.class.children_types.first.to_s)
    child_statements(language_ids, type, true)
  end

  # Get the top children of a specific child type
  def get_paginated_child_statements(language_ids = nil,
                                     type = self.class.children_types.first.to_s,
                                     page = 1,
                                     per_page = TOP_CHILDREN)
    type_class = type.constantize
    children = child_statements(language_ids, type)
    type_class.paginate_statements(children, page, per_page)
  end


  ###################
  # CHILDREN HELPER #
  ###################

  def id_as_parent
    self.id
  end


  private

  #################
  # Class methods #
  #################

  class << self

    def new_instance(attributes = nil)
      self.new(attributes)
    end

    def is_top_statement?
      false
    end

    def paginate_statements(children, page, per_page)
      children.paginate(default_scope.merge(:page => page, :per_page => per_page))
    end

    def statements_for_parent(parent_id, language_ids = nil, filter_drafting_state = false, for_session = false)
      do_statements_for_parent(parent_id, language_ids, filter_drafting_state, for_session)
    end

    def do_statements_for_parent(parent_id, language_ids = nil, filter_drafting_state = false, for_session = false)
      conditions = {:conditions => "n.type = '#{self.name}' and n.parent_id = #{parent_id}"}
      conditions.merge!({:language_ids => language_ids}) if language_ids
      conditions.merge!(special_query_conditions) if filter_drafting_state

      statements = self.search_statement_nodes(conditions)
      if for_session
        statements.map!(&:id)
        statements << "/#{parent_id.nil? ? '' : "#{parent_id}/" }add/#{self.name.underscore}"
      end
      statements
    end

    def special_query_conditions
      {}
    end

    def join_clause
      <<-END
        select distinct n.*
        from
          statement_nodes n
          LEFT JOIN statement_documents d    ON n.statement_id = d.statement_id
          LEFT JOIN tao_tags tt              ON (tt.tao_id = n.id and tt.tao_type = 'StatementNode')
          LEFT JOIN tags t                   ON tt.tag_id = t.id
          LEFT JOIN echos e                  ON n.echo_id = e.id
        where
      END
    end


    public

    def search_statement_nodes(opts={})

      # Building the search clause
      select_clause = join_clause

      # Building the where clause
      # Handling the search term
      search_term = opts[:search_term]
      if !search_term.blank?
        terms = search_term.split(" ")
        search_fields = %w(d.title d.text)
        or_conditions = search_fields.map{|attr|"#{attr} LIKE ?"}.join(" OR ")
        or_conditions << " OR #{terms.map{|term| term.length > 3 ?
                          sanitize_sql(["t.value LIKE ?","%#{term}%"]) :
                          sanitize_sql(["t.value = ?",term])}.join(" OR ")}"
      end
      and_conditions = !or_conditions.blank? ? ["(#{or_conditions})"] : []

      # Filter for statement type
      if opts[:conditions].nil?
        and_conditions << "n.type = '#{opts[:type]}'"
        # Filter for published statements
        and_conditions << sanitize_sql(["n.editorial_state_id = ?", StatementState['published'].id]) unless opts[:show_unpublished]
        # Filter for featured topic tags (categories)
        #and_conditions << sanitize_sql(["t.value = ?", opts[:category]]) if opts[:category]
      else
        and_conditions << opts[:conditions]
      end
      # Filter for the preferred languages
      and_conditions << sanitize_sql(["d.language_id IN (?)", opts[:language_ids]]) if opts[:language_ids]
      # Filter for drafting states
      and_conditions << sanitize_sql(["n.drafting_state IN (?)", opts[:drafting_states]]) if opts[:drafting_states]
      # Constructing the where clause
      where_clause = and_conditions.join(" AND ")

      # Building the order clause
      order_clause = " order by e.supporter_count DESC, n.created_at DESC;"

      # Composing the query and substituting the values
      query = select_clause + where_clause + order_clause
      value = "%#{search_term}%"
      conditions = search_fields ? [query, *([value] * search_fields.size)] : query

      # Executing the query
      find_by_sql(conditions)
    end

    def default_scope
      { :include => :echo,
        :order => %Q[echos.supporter_count DESC, created_at ASC] }
    end



    def children_types(children_visibility = false)
      children_types = @@children_types[self.name] || @@children_types[self.superclass.name]
      return children_types.map{|c|c[0]} if !children_visibility
      children_types
    end

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

    def default_children_types(*klasses)
      @@default_children_types = klasses
    end

    def has_children_of_types(*klasses)
      @@children_types ||= { }
      @@children_types[self.name] ||= @@default_children_types.nil? ? [] : @@default_children_types
      @@children_types[self.name] = klasses + @@children_types[self.name]
    end
  end
  default_children_types [:FollowUpQuestion,false]
end
