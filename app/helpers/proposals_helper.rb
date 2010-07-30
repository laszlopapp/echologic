module ProposalsHelper
  
  def incorporate_proposal_path(improvement_proposal)
    incorporate_question_proposal_path(improvement_proposal.root, improvement_proposal.parent)
  end
  
  def incorporate_statement_node_link(statement_node, statement_document)
    if current_user and
       statement_document.author == current_user and 
       statement_node.published? and
       statement_node.original_language.code.eql?(I18n.locale.to_s)
      link_to(I18n.t('application.general.incorporate'), incorporate_proposal_path(statement_node),
              :class => 'ajax header_button text_button incorporate_text_button')
    end
  end
end