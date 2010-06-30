class StatementDocument < ActiveRecord::Base
  #has_many :statements, :foreign_key => 'document_id'
  belongs_to :statement
  belongs_to :author, :class_name => "User"
  belongs_to :translated_document, :class_name => 'StatementDocument'
  has_many :statement_nodes, :through => :statement, :source => :statement_nodes
  validates_presence_of :title
  validates_presence_of :text
  validates_presence_of :author_id
  validates_presence_of :language_id
  validates_presence_of :statement
  validates_associated :author    
  
  enum :language, :enum_name => :languages

  # returns if the document is an original or a translation
  def original?
    self.translated_document_id.nil?
  end

  # returns the translated_document, declaring it as the original
  def original
    self.translated_document.original? ? self.translated_document : self.translated_document.original
  end

  # returns all translations of self
  def translations
    StatementDocument.find_all_by_translated_document_id(self.id)
  end
  
  def self.search_statement_documents(statement_ids, language_keys, opts={} )
      
      #Rambo 1
      query_part_1 = <<-END
          select distinct sd.title, sd.statement_id, sd.language_id
          from
            statement_documents sd
            where
      END
      #Rambo 2
      query_part_2 = sanitize_sql([" sd.statement_id IN (?) AND sd.language_id IN (?)", statement_ids, language_keys])
      #Rambo 3
      query_part_3 = " order by sd.language_id;"

      #All Rambo's in one
      query = query_part_1+query_part_2+query_part_3
      statement_nodes = find_by_sql(query)
    end
end
