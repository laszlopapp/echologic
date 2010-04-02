class Proposal < StatementNode
  validates_parent :Question
  expects_children :ImprovementProposal
end
