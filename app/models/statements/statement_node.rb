class StatementNode < ActiveRecord::Base
  acts_as_extaggable :topics
  acts_as_subscribeable
  acts_as_echoable

  after_destroy :destroy_statement

  def destroy_statement
    self.statement.destroy if (statement.statement_nodes - [self]).empty?
  end

  ##
  ## ASSOCIATIONS
  ##

  belongs_to :creator, :class_name => "User"
  belongs_to :root_statement, :foreign_key => "root_id", :class_name => "StatementNode"
  belongs_to :statement

  delegate :original_language, :document_in_original_language, :authors, :to => :statement

  enum :editorial_state, :enum_name => :statement_states

  acts_as_tree :scope => :root_statement

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


  def validate
    # except of questions, all statements need a valid parent
    errors.add("Parent of #{self.class.name} must be of one of #{self.class.valid_parents.inspect}") unless
      self.class.valid_parents and self.class.valid_parents.select { |k| parent.instance_of?(k.to_s.constantize) }.any?
  end

  ##
  ## NAMED SCOPES
  ##

  named_scope :questions, lambda {
    { :conditions => { :type => 'Question' } } }
  named_scope :proposals, lambda {
    { :conditions => { :type => 'Proposal' } } }
  named_scope :improvement_proposals, lambda {
    { :conditions => { :type => 'ImprovementProposal' } } }
  named_scope :published, lambda {|auth|
    { :conditions => { :editorial_state_id => statement_states('published').id } } unless auth }
  named_scope :by_creator, lambda {|id|
  {:conditions => ["creator_id = ?", id]}}

  # orders
  named_scope :by_ratio, :include => :echo, :order => '(echos.supporter_count/echos.visitor_count) DESC'
  named_scope :by_supporters, :include => :echo, :order => 'echos.supporter_count DESC'
  named_scope :by_creation, :order => 'created_at DESC'


  ## ACCESSORS

  def title
    raise 'title is deprecated... please use translated_document().title instead'
  end

  def text
    raise 'text is deprecated... please use translated_document().title instead'
  end

  def level
    # simple hack to gain the level
    # problem is: as we can't use nested set (too write intensive stuff),
    # we can't easily get the statement_nodes level in the tree
    level = 0
    level += 1 if self.parent
    level += 1 if self.root && self.root != self && self.root != self.parent
    level
  end


  ##############################
  ######### ACTIONS ############
  ##############################

  # static for now
  def published?
    self.editorial_state == self.class.statement_states("published")
  end

  # Publish a statement.
  def publish
    self.editorial_state = self.class.statement_states("published")
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
    original_language_id = attributes.delete(:original_language_id)
    self.statement = Statement.new(:original_language_id => original_language_id) if self.statement.nil?
    doc = StatementDocument.new
    attributes.each {|k,v|doc.send("#{k.to_s}=", v)}
    doc.statement = self.statement
    self.statement.statement_documents << doc
    return doc
  end

  # creates and saves a  statement_document with given parameters a
  def add_statement_document!(*args)
    original_language_id = args[0].delete(:original_language_id)
    self.statement = Statement.new(:original_language_id => original_language_id) if self.statement.nil?
    doc = StatementDocument.new(:statement_id => self.statement.id)
    doc.statement = self.statement
    doc.update_attributes!(*args)
    self.statement.statement_documents << doc
    return doc
  end


  # Checks if there is no document written in the given language code and the current user can translate it.
  def translatable?(user,from_language,to_language,language_preference_list)
    if user
      # 1.we have a current user that speaks languages
      !user.spoken_languages.blank? and
      # 2.the user has a mother tongue
      !user.mother_tongues.blank? and
      # 3.current text language is different from the current language,
      # which means there is no translated version of the document yet in the current language
      !from_language.code.eql?(to_language) and
      # 4.application language is the current user's mother tongue
      user.mother_tongues.collect{|l| l.code}.include?(to_language) and
      # 5.user knows the document's language
      user.spoken_languages.map{|sp| sp.language}.uniq.include?(from_language) and
      # 6. user has language level greater than intermediate
      %w(intermediate advanced mother_tongue).include?(
        user.spoken_languages.select {|sp| sp.language == from_language}.first.level.code)
    else
      false
    end
  end

  # Checks if, in case the user hasn't yet set his language knowledge, the current language is different from
  # the statement original language. used for the original message warning
  def not_original_language?(user, current_language_id)
    user ? (user.spoken_languages.empty? and current_language_id != original_language.id) : false
  end

  ###############################
  ##### ACTS AS TREE METHOD #####
  ###############################

  # Recursive method to get all parents...
  def parents(parents = [])
    obj = self
    while obj.parent && obj.parent != obj
      parents << obj = obj.parent
    end
    parents.reverse!
  end

  def self_with_parents()
    list = parents([self])
    list.size == 1 ? list.pop : list
  end

  # Collects a filtered list of all children statements
  def children_statements(language_ids = nil)
    return children_statements_for_parent(self.id, language_ids)
  end

  # Collects a filtered list of all siblings statements
  def sibling_statements(language_ids = nil)
    return parent_id.nil? ? [] : children_statements_for_parent(self.parent_id, language_ids)
  end


  private

  def children_statements_for_parent(parent_id, language_ids = nil)
    conditions = {:conditions => "parent_id = #{parent_id}"}
    conditions.merge!({:language_ids => language_ids}) if language_ids
    conditions.merge!({:drafting_states => %w(tracked ready staged)}) if self.draftable?
    children = self.class.search_statement_nodes(conditions)
    children
  end


  #################
  # Class methods #
  #################

  class << self

    public

    def search_statement_nodes(opts={})

      # Building the search clause
      select_clause = <<-END
        select distinct n.*
        from
          statement_nodes n
          LEFT JOIN statement_documents d    ON n.statement_id = d.statement_id
          LEFT JOIN tao_tags tt              ON (tt.tao_id = n.id and tt.tao_type = 'StatementNode')
          LEFT JOIN tags t                   ON tt.tag_id = t.id
          LEFT JOIN echos e                  ON n.echo_id = e.id
        where
      END

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
        and_conditions << sanitize_sql(["n.editorial_state_id = ?", statement_states('published').id]) unless opts[:show_unpublished]
        # Filter for featured topic tags (categories)
        and_conditions << sanitize_sql(["t.value = ?", opts[:category]]) if opts[:category]
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
      order_clause = " order by e.supporter_count DESC, n.created_at asc;"

      # Composing the query and substituting the values
      query = select_clause + where_clause + order_clause
      value = "%#{search_term}%"
      conditions = search_fields ? [query, *([value] * search_fields.size)] : query

      # Executing the query
      statement_nodes = find_by_sql(conditions)
    end

    def valid_parents
      @@valid_parents[self.name]
    end

    def expected_children
      @@expected_children[self.name]
    end

    def default_scope
      { :include => :echo,
        :order => %Q[echos.supporter_count DESC, created_at ASC] }
    end


    def expected_parent_chain
      chain = []
      obj_class = self.name.constantize
      while !obj_class.valid_parents.first.nil?
        chain << obj = self.valid_parents.first
      end
      chain
    end

    private
    # takes an array of class names that are valid for the parent association.
    # the class names should either be strings or symbols, no constants. They
    # will be constantized within the instance, hence won't place a loading
    # constraint on the models (which might lead to loops in our case)
    def validates_parent(*klasses)
      @@valid_parents ||= { }
      @@valid_parents[self.name] ||= []
      @@valid_parents[self.name] += klasses
    end

    # takes an array of class names that are expected to be children of this class
    # this could also be generated by checking all other subclasses valid_parents
    # but i think it is more convenient to define them extra
    # at the moment we only show one type of children in the questions children container (view)
    # therefor we will look for the first element of the expected_children array
    def expects_children(*klasses)
      @@expected_children ||= { }
      @@expected_children[self.name] ||= []
      @@expected_children[self.name] += klasses
    end
  end

end
