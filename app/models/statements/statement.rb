class Statement < ActiveRecord::Base
  has_many :statement_nodes
  has_many :statement_documents, :dependent => :destroy
  belongs_to :statement_image
  delegate :image, :image=, :to => :statement_image
  
  
  validates_associated :statement_documents

  has_many :statement_histories, :source => :statement_histories

  def after_initialize
    self.statement_image = StatementImage.new if self.statement_image.nil?
  end

  def authors
    statement_histories.by_creation.by_language(self.original_language_id).map(&:author).uniq
  end

  def has_author? user
    user.nil? ? false : authors.map(&:id).include?(user.id)
  end

  has_enumerated :original_language, :class_name => 'Language'

  named_scope :find_by_title, lambda {|value|
            { :include => :statement_documents, :conditions => ['statement_documents.title LIKE ? and statement_documents.current = 1', "%#{value}%"] } }


  #
  # Returns the current statement document in the given language.
  #
  def document_in_language(language)
    self.statement_documents.find(:first, :conditions => ["language_id = ? and current = 1", language.id])
  end
end
