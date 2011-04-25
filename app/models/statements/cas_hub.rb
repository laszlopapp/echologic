class CasHub < StatementNode
  
  has_many :alternative_statements, :foreign_key => 'parent_id'
  
  def is_hub?
    true
  end
end