class StatementDocument < ActiveRecord::Base

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
  validates_uniqueness_of :language_id, :scope => :statement_id

  enum :language, :enum_name => :languages


  # Returns if the document is an original or a translation
  def original?
    self.translated_document_id.nil?
  end

  # Returns the translated_document, declaring it as the original
  def original
    self.translated_document.original? ? self.translated_document : self.translated_document.original
  end

  # Returns all translations of self
  def translations
    StatementDocument.find_all_by_translated_document_id(self.id)
  end
end
