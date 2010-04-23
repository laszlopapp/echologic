class StatementDocument < ActiveRecord::Base
  #has_many :statements, :foreign_key => 'document_id'
  belongs_to :statement
  belongs_to :author, :class_name => "User"
  belongs_to :translated_document, :class_name => 'StatementDocument'
  validates_presence_of :title
  validates_presence_of :text
  validates_associated :author
  validates_presence_of :author_id
  validates_presence_of :language_id
  validates_presence_of :statement_id
  validates_associated :statement
  
  language_enum
  language_level_enum
  
  # returns if the document is an original or a translation
  def original?
    self.translated_document_id.nil?
  end 
  
  # returns the translated_document, declaring it as the original
  def original
    self.translated_document
  end
  
  # returns all translations of self
  def translations
    StatementDocument.find_all_by_translated_document_id(self.id)
  end
end
