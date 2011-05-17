class StatementDocument < ActiveRecord::Base

  belongs_to :statement
  has_many :statement_nodes, :through => :statement, :source => :statement_nodes

  has_one :statement_history, :dependent => :destroy

  belongs_to :locked_by, :class_name => "User", :foreign_key => 'locked_by'

  has_enumerated :language, :class_name => 'Language'

  validates_presence_of :title
  validates_length_of :title, :maximum => 101
  validates_presence_of :text
  validates_presence_of :language_id
  validates_presence_of :statement
  validates_associated :statement_history

  before_validation :set_history
  
  delegate :author, :author=, :author_id=, :action, :action=, :action_id=, :old_document, :old_document=, :old_document_id=,
           :incorporated_node, :incorporated_node=, :incorporated_node_id=, :comment, :comment=, :to => :statement_history


  def after_initialize
    self.statement_history = StatementHistory.new if self.statement_history.nil?
  end

  def set_history
    self.statement_history.statement = self.statement
  end

  # Returns if the document is an original or a translation
  def original?
    self.old_document.nil?
  end

  # Returns the translated_document, declaring it as the original
  def original
    self.original? ? self : self.old_document.original
  end

  def lock(user)
    self.locked_by = user
    self.locked_at = Time.now
    save
  end

  def unlock
    self.locked_by = nil
    self.locked_at = nil
    save
  end

  # Returns all translations of self
  def translations
    #StatementDocument.find_all_by_translated_document_id(self.id)
    StatementDocument.all(:joins => :statement_history,
    :conditions => ["#{StatementHistory.table_name}.old_document_id = ? AND #{self.class.table_name}.language_id != ?",
                    self.id, self.language.id])
  end

  #
  # gets a set of current statement documents given an hash of arguments
  #
  # opts attributes:
  #
  # statement_ids (Array[Integer]) : array of statement ids which we have to search the documents through
  # language_ids (Array[Integer])  : filters out documents which language is not included on the array
  # 
  # the rest of the opts hash works as a normal ActiveRecord query array; check documentation if you have doubts about it
  #
  def self.search_statement_documents(opts={})
      opts.delete(:readonly)
      
      opts[:select] = "DISTINCT #{table_name}.id, " + 
                                 "#{table_name}.title, " + 
                                 "#{table_name}.statement_id, " + 
                                 "#{table_name}.language_id, " +
                                 "#{table_name}.current"
      # insert more elements to be taken to the model if needed
      more = opts.delete(:more).map{|m|"#{table_name}.#{m}"} if opts[:more]
      opts[:select] << ", #{more.join(', ')}" if more
      
      # join will be important to get the original document
      opts[:joins] = :statement if opts[:user].nil? or opts[:user].spoken_languages.empty?
      
      and_conditions = []
      and_conditions << "#{table_name}.current = 1"
      and_conditions << sanitize_sql(["#{table_name}.statement_id IN (?)", opts.delete(:statement_ids)])
      # if there is no user, get the document in local language, or, if it does not exist, get the original
      if (user = opts.delete(:user)).nil? or user.spoken_languages.empty?
        and_conditions << sanitize_sql(["(#{table_name}.language_id IN (?) OR " +
                                        "#{table_name}.language_id = #{Statement.table_name}.original_language_id)", 
                                        opts.delete(:language_ids)])
      else
        and_conditions << sanitize_sql(["#{table_name}.language_id IN (?)", opts.delete(:language_ids)])
      end
      opts[:conditions] ||= and_conditions.join(" AND ")
      opts[:order] ||= "#{table_name}.language_id" 
      all opts
    end
end
