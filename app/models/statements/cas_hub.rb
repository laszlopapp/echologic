class CasHub < StatementNode
  
  has_many :alternatives, :class_name => "StatementNode", :foreign_key => 'parent_id'

  belongs_to :alternative_follow_up_question, :foreign_key => 'question_id'
  
end