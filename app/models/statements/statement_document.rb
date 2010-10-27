class StatementDocument < ActiveRecord::Base

  belongs_to :statement
  has_many :statement_nodes, :through => :statement, :source => :statement_nodes

  has_one :statement_history, :dependent => :destroy

  belongs_to :locked_by, :class_name => "User", :foreign_key => 'locked_by'

  has_enumerated :language, :class_name => 'Language'

  validates_presence_of :title
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
    :conditions => ["statement_histories.old_document_id = ? AND statement_documents.language_id != ?",
                    self.id, self.language.id])
  end

  def self.search_statement_documents(statement_ids, language_ids, opts={} )

      #Rambo 1
      query_part_1 = <<-END
          select distinct sd.title, sd.statement_id, sd.language_id, sd.current
          from
            statement_documents sd
            where
      END
      #Rambo 2
      query_part_2 = sanitize_sql(["sd.current = 1 AND sd.statement_id IN (?) AND sd.language_id IN (?) ",
                                   statement_ids, language_ids])
      #Rambo 3
      query_part_3 = " order by sd.language_id;"

      #All Rambo's in one
      query = query_part_1+query_part_2+query_part_3
      statement_nodes = find_by_sql(query)
    end
end
