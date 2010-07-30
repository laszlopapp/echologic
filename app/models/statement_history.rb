class StatementHistory < ActiveRecord::Base
  
  # Main foreign keys
  belongs_to :statement
  belongs_to :statement_document
  
  # Secondary foreign keys
  belongs_to :old_document, :class_name => 'StatementDocument'
  belongs_to :incorporated_node, :class_name => 'StatementNode'
    
  belongs_to :author, :class_name => "User"
    
  
  enum :action, :enum_name => :statement_actions
  
  
  # Validations
  
  validates_presence_of :author_id
  validates_presence_of :action_id
  validates_associated :author
  
end
