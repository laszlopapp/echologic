class Statement < ActiveRecord::Base
  has_many :statement_nodes
  has_many :statement_documents, :dependent => :destroy
  validates_associated :statement_documents

  enum :original_language, :enum_name => :languages

  named_scope :find_by_title, lambda {|value|
            { :include => :statement_documents, :conditions => ['statement_documents.title LIKE ?', "%#{value}%"] } }
            
  
end
