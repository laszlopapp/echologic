class CasHub < StatementNode
  
  has_many :alternatives, :class_name => "StatementNode", :foreign_key => 'parent_id'
  
  def is_hub?
    true
  end
end