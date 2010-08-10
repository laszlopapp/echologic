module ProposalsHelper
  
  def incorporate_proposal_path(improvement_proposal)
    incorporate_question_proposal_path(improvement_proposal.root, improvement_proposal.parent)
  end
  
  def incorporate_statement_node_link(parent_node, parent_document, statement_node, statement_document)
    if current_user and statement_node.published? and
      parent_document.language.eql?(parent_node.original_language) and
      statement_document.language.eql?(parent_node.original_language) and
      ((statement_node.times_passed == 0 and statement_document.author == current_user) or
       (statement_node.times_passed == 1 and statement_node.supported?(current_user)))
      link_to(I18n.t('application.general.incorporate'), incorporate_proposal_path(statement_node),
              :class => 'ajax header_button text_button incorporate_text_button')
    end
  end
end