class Statement < ActiveRecord::Base
  has_many :statement_nodes
  has_many :statement_documents
  
  enum :original_languages, :name => :languages
  
  named_scope :find_by_title, lambda {|value|
            { :include => :statement_documents, :conditions => ['statement_documents.title LIKE ?', "%#{value}%"] } }
end
