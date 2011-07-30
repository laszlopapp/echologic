class CasHub < StatementNode
  
  has_many :alternatives, :class_name => "StatementNode", :foreign_key => 'parent_id'
  
  def target_id
    parent_id  
  end
  
end