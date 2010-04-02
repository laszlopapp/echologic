class Statement < ActiveRecord::Base
  has_many :statement_nodes
  has_many :statement_documents  
end
