class StatementNode < ActiveRecord::Base
  include Echoable

  # magically allows Proposal.first.question? et al.
  #
  # FIXME: figure out why this sometimes doesn't work, but only in ajax requests
#  def method_missing(sym, *args)
#    sym.to_s =~ /\?$/ && ((klass = sym.to_s.chop.camelize.constantize) rescue false) ? klass == self.class : super
#  end

  # static for now

  def proposal?
    self.class == Proposal
  end

  def improvement_proposal?
    self.class == ImprovementProposal
  end

  def question?
    self.class == Question
  end

  def published?
    self.state == self.class.statement_states("published")
  end

  def taggable?
    false
  end


  ##
  ## ASSOCIATIONS
  ##

  belongs_to :creator, :class_name => "User"
  belongs_to :root_statement, :foreign_key => "root_id", :class_name => "StatementNode"
  belongs_to :statement
  has_many :tao_tags, :as => :tao, :dependent => :destroy
  has_many :tags, :through => :tao_tags

  enum :state, :enum_name => :statement_states

  acts_as_tree :scope => :root_statement
  # not yet implemented
  #belongs_to :work_packages

  has_many :statement_documents, :through => :statement, :source => :statement_documents do
    # this query returns translation for a statement ordered by the users preferred languages
    # OPTIMIZE: this should be built in sql

    def for_languages(lang_ids)
      find(:all, :conditions => ["language_id IN (?)", lang_ids]).sort {
         |a, b| lang_ids.index(a.language_id) <=> lang_ids.index(b.language_id)
      }.first
    end
  end

  ##
  ## VALIDATIONS
  ##


  validates_presence_of :state_id
  validates_numericality_of :state_id
  validates_presence_of :creator_id
  validates_presence_of :statement
  validates_associated :creator
  validates_associated :statement
  validates_associated :tao_tags

  after_destroy :delete_dependencies


  def delete_dependencies
    self.statement.destroy if self.statement.statement_nodes.empty?
  end

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
  named_scope :arguments, lambda {
    { :conditions => ['type = ? OR type = ?', 'ProArgument', 'ContraArgument'] } }
  named_scope :pro_arguments, lambda {
    { :conditions => { :type => 'ProArgument' } } }
  named_scope :contra_arguments, lambda {
    { :conditions => { :type => 'ContraArgument' } } }
  named_scope :published, lambda {|auth|
    { :conditions => { :state_id => statement_states('published').id } } unless auth }

  #this name scope doesn't work
  named_scope :by_title, lambda {|value|
  {:joins => [:statement_documents], :conditions => ["statement_documents.title like ?", "%"+value+"%"]}}
  named_scope :by_creator, lambda {|id|
  {:conditions => ["creator_id = ?", id]}}
  # orders
  named_scope :by_ratio, :include => :echo, :order => '(echos.supporter_count/echos.visitor_count) DESC'
  named_scope :by_supporters, :include => :echo, :order => 'echos.supporter_count DESC'
  named_scope :by_creation, :order => 'created_at DESC'

  #context
  named_scope :from_context, lambda { |context_ids|
    { :include => :tao_tags, :conditions => ['tao_tags.context_id IN (?)', context_ids] } }
  # tag
  named_scope :from_tags, lambda { |value|
    { :include => :tags, :conditions => ['tags.value = ?', value] } }


  ## ACCESSORS

  def title
    raise 'title is deprecated... please use translated_document().title instead'
    #self.translated_document(1).title
  end

  def text
    raise 'text is deprecated... please use translated_document().title instead'
    #self.translated_document(1).text
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


  def publish
    self.state = self.class.statement_states("published")
  end

  # returns a translated document for passed language_codes (or nil if none is found)
  def translated_document(lang_ids)
    @current_document ||= statement_documents.for_languages(lang_ids)
  end

  def translated_document?(lang_ids)
    return statement_documents.for_languages(lang_ids).nil?
  end


  # creates a new statement_document
  def add_statement_document(attributes={ },opts={})
    original_language_id = attributes.delete(:original_language_id)
    doc = StatementDocument.new(attributes)
    self.statement = Statement.new(:original_language_id => original_language_id) if self.statement.nil?
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

  def add_tags(tags, opts = {})
    self.tao_tags << TaoTag.create_for(tags,
                                       opts[:language_id],
                                       {:tao_id => self.id,
                                        :tao_type => "StatementNode",
                                        :context_id => TaoTag.tag_contexts("topic").id})
  end

  def delete_tags(tags)
    self.tao_tags.each {|tao_tag| tao_tag.destroy if tags.include?(tao_tag.tag.value)}
  end

  ###############################
  ##### ACTS AS TREE METHOD #####
  ###############################

  # recursive method to get all parents...
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

  class << self

    # Custom SQL for querying statement nodes in Discuss / Search
    def search_statement_nodes(type, search_term, language_keys, opts={} )

      # Building the search clause
      search_clause = <<-END
        select distinct n.*
        from
          statement_nodes n
          LEFT JOIN statement_documents d    ON n.statement_id = d.statement_id 
          LEFT JOIN tao_tags tt              ON tt.tao_id = n.id
          LEFT JOIN tags t                   ON tt.tag_id = t.id
          LEFT JOIN echos e                  ON n.echo_id = e.id
        where
      END

      # Building the where clause
      tags = opts[:category] || search_term.split(" ")

      # Handling the search term
      if !search_term.blank?
        search_fields = %w(d.title d.text)
        or_conditions = search_fields.map{|attr|"#{attr} LIKE ?"}.join(" OR ")
        or_conditions << "OR #{tags.map{|tag| tag.length > 3 ?
                          sanitize_sql(["t.value LIKE ?","%#{tag}%"]) :
                          sanitize_sql(["t.value = ?",tag])}.join(" OR ")}"
      end
      and_conditions << "(#{or_conditions})" if or_conditions

      # Filter for statement type
      and_conditions = opts[:conditions] || ["n.type = '#{type}'"]
      # Filter for published statements
      and_conditions << sanitize_sql(["n.state_id = ?", statement_states('published').id]) if opts[:auth]
      # Filter for featured topic tags (categories)
      and_conditions << sanitize_sql(["t.value = ?", opts[:category]]) if opts[:category]
      # Filter for the preferred languages
      and_conditions << sanitize_sql(["d.language_id IN (?)", language_keys])

      # Constructing the where clause
      where_clause = and_conditions.join(" AND ")

      # Building the order clause
      order_clause = " order by e.supporter_count DESC, n.created_at asc;"

      # Composing the query and substituting the values
      query = search_clause + where_clause + order_clause
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

    def display_name
      self.name.underscore.gsub(/_/,' ').split(' ').each{|word| word.capitalize!}.join(' ')
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
