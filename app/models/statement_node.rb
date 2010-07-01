class StatementNode < ActiveRecord::Base
  include Echoable
  acts_as_subscribeable
  acts_as_extaggable #had to throw this here, because of the event json generation (tao_tags)
  # magically allows Proposal.first.question? et al.
  #
  # FIXME: figure out why this sometimes doesn't work, but only in ajax requests
#  def method_missing(sym, *args)
#    sym.to_s =~ /\?$/ && ((klass = sym.to_s.chop.camelize.constantize) rescue false) ? klass == self.class : super
#  end

  # static for now
  def published?
    self.state == self.class.statement_states("published")
  end

  ##
  ## ASSOCIATIONS
  ##
 
  belongs_to :creator, :class_name => "User"
  belongs_to :root_statement, :foreign_key => "root_id", :class_name => "StatementNode"
  belongs_to :statement

  enum :state, :enum_name => :statement_states

  acts_as_tree :scope => :root_statement
  # not yet implemented
  #belongs_to :work_packages

  has_many :statement_documents, :through => :statement, :source => :statement_documents do
    # this query returns translation for a statement ordered by the users prefered languages
    # OPTIMIZE: this should be built in sql

    def for_languages(lang_ids)
      # doc = find(:all, :conditions => ["translated_statement_id = ? AND language_code = ?", nil, lang_codes.first]).first
      find(:all, :conditions => ["language_id IN (?)", lang_ids]).sort { |a, b| lang_ids.index(a.language_id) <=> lang_ids.index(b.language_id)}.first
    end
  end
  
  
  ##
  ## VALIDATIONS
  ##


  validates_presence_of :state_id
  validates_presence_of :creator_id
  validates_presence_of :statement
  validates_numericality_of :state_id
  validates_associated :creator
  validates_associated :statement
  
  after_destroy :delete_dependencies

  def delete_dependencies
    self.statement.destroy if self.statement.statement_nodes.empty?
  end

  def validate
    # except of questions, all statements need a valid parent
    errors.add("Parent of #{self.class.name} must be of one of #{self.class.valid_parents.inspect}") unless self.class.valid_parents and self.class.valid_parents.select { |k| parent.instance_of?(k.to_s.constantize) }.any?
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
    { :conditions => { :state_id => statement_states('published').id } } unless auth }
  named_scope :by_creator, lambda {|id|
  {:conditions => ["creator_id = ?", id]}}
  
  
  
  # orders
  named_scope :by_ratio, :include => :echo, :order => '(echos.supporter_count/echos.visitor_count) DESC'
  named_scope :by_supporters, :include => :echo, :order => 'echos.supporter_count DESC'
  named_scope :by_creation, :order => 'created_at DESC'

  


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
    # problem is: as we can't use nested set (too write intensive stuff), we can't easily get the statement_nodes level in the tree
    level = 0
    level += 1 if self.parent
    level += 1 if self.root && self.root != self && self.root != self.parent
    level
  end

  ##############################
  ######### ACTIONS ############
  ##############################


  #publish a statement
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


  # checks if there is no document written in the current language code and the current user can translate it
  def translatable?(user,from_language,to_language,language_preference_list)
    if user
      # 1.we have a current user that speaks languages
      !user.spoken_languages.blank? and
      # 2.we ensure ourselves that the user has a mother tongue
      !user.mother_tongues.blank? and
      # 3.current text language is different from the current language,
      # which would mean there is no translated version of the document yet in the current language
      !from_language.code.eql?(to_language) and
      # 4.application language is the current user's mother tongue
      user.mother_tongues.collect{|l| l.code}.include?(to_language) and
      # 5.user knows the document's language
      user.spoken_languages.map{|sp| sp.language}.uniq.include?(from_language) and
      #6. user has language level greater than intermediate
      %w(intermediate advanced mother_tongue).include?(
        user.spoken_languages.select {|sp| sp.language == from_language}.first.level.code)
    else
      false
    end
  end

  # checks if, in case the user hasn't yet set his language knowledge, the current language is different from
  # the statement original language. used for the original message warning
  def not_original_language?(user, current_language_id)
    user ? (user.spoken_languages.empty? and current_language_id != self.statement.original_language.id) : false
  end

  

  # Updates the tags belonging to a question (other statement types do not have any tags yet).
  def update_tags(tags, language_id)
    new_tags = tags.split(',').map{|t|t.strip}.uniq
    tags_to_delete = self.tags.collect{|tag|tag.value} - new_tags
    self.add_tags(new_tags, :language_id => language_id, 
                            :tao_type => "StatementNode",
                            :context_id => TaoTag.tag_contexts("topic").id) unless new_tags.nil?
    self.delete_tags tags_to_delete
    new_tags
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



  # that collects all children, sorted in the way we want them to
  def sorted_children(user, language_keys)
    children = self.class.search_statement_nodes(:language_keys => language_keys, 
                                                 :auth => user && user.has_role?(:editor), 
                                                 :conditions => ["parent_id = ?", self.parent.id])
    children = self.children.published(user && user.has_role?(:editor)).by_supporters
    #additional step: to filter statement_nodes with a translated version in the current language
    children = children.select{|s| !(language_keys & s.statement_documents.collect{|sd| sd.language_id}).empty?}
  end
  
  class << self

    def search_statement_nodes(opts={} )

      value = opts[:value] || ""
      #get tags
      tags = opts[:tag] || value.split(" ")

      #sorting the or arguments
      if !value.blank?
        or_attrs = opts[:or_attrs] || %w(d.title d.text)
        or_conditions = or_attrs.map{|attr|"#{attr} LIKE ?"}.join(" OR ")
        or_conditions << "OR #{tags.map{|tag| tag.length > 3 ?
                          sanitize_sql(["t.value LIKE ?","%#{tag}%"]) :
                          sanitize_sql(["t.value = ?",tag])}. join(" OR ")}"
      end
      #sorting the and arguments
      and_conditions = opts[:conditions] || ["n.type = '#{opts[:type]}'"]
      and_conditions << "n.state_id = #{statement_states('published').id}" if opts[:auth]
      and_conditions << sanitize_sql(["t.value = ?", opts[:tag]]) if opts[:tag]
      and_conditions << sanitize_sql(["d.language_id IN (?)",opts[:language_keys]]) if opts[:language_keys]
      and_conditions << sanitize_sql(["t.value = ?", opts[:tag]]) if opts[:tag]

      #all getting along like really good friends
      and_conditions << "(#{or_conditions})" if or_conditions

      #Rambo 1
      query_part_1 = <<-END
        select distinct n.*
        from
          statement_nodes n
          LEFT JOIN statements s             ON n.statement_id = s.id
          LEFT JOIN statement_documents d    ON s.id = d.statement_id
          LEFT JOIN tao_tags tt              ON tt.tao_id = n.id
          LEFT JOIN tags t                   ON tt.tag_id = t.id
          LEFT JOIN echos e                  ON n.echo_id = e.id
        where
      END
      #Rambo 2
      query_part_2 = and_conditions.join(" AND ")
      #Rambo 3
      #TODO: doesn't order by supporter count!!!!!!!!!!!!!!!
      query_part_3 = " order by e.supporter_count DESC, n.created_at asc;"

      #All Rambo's in one
      query = query_part_1+query_part_2+query_part_3
      value = "%#{value}%"

      conditions = or_attrs ? [query, *([value] * or_attrs.size)] : query
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
