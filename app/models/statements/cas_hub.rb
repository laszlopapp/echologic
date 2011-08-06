class CasHub < StatementNode
  
  has_many :alternatives, :class_name => "StatementNode", :foreign_key => 'parent_id'

  belongs_to :discuss_alternatives_question, :foreign_key => 'question_id'
  belongs_to :twin_hub, :class_name => "CasHub"
  
  def target_id
    parent_id
  end
  
end