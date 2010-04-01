class StatementDocument < ActiveRecord::Base
  #has_many :statements, :foreign_key => 'document_id'
  belongs_to :statement
  belongs_to :author, :class_name => "User"
  belongs_to :original, :class_name => 'StatementDocument', :foreign_key => :translated_document_id
  
  validates_presence_of :title
  validates_presence_of :text
  validates_associated :author
  validates_presence_of :author_id
  validates_presence_of :language_id
  validates_presence_of :statement_id
  validates_associated :statement
  
  # returns if the document is an original or a translation
  def original?
    self.translated_document_id.nil?
  end 
  
  def self.languages
    EnumKey.find_all_by_name('languages')
  end
  
  def language
    EnumKey.find_by_name_and_key('languages', language_id)
  end
  
  # returns if the document is an original or a translation
  def original?
    self.translated_document_id.nil?
  end
  
end
