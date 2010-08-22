module ProposalsHelper

  def incorporate_proposal_path(improvement_proposal)
    url_for hash_for_incorporate_question_proposal_path.merge(:approved_ip => improvement_proposal.id)
  end

  def incorporate_statement_node_link(parent_node, parent_document, statement_node, statement_document)
    if !current_user or 
       (statement_node.published? and
        parent_document.language == statement_node.drafting_language and
        statement_document.language. == statement_node.drafting_language and
        ((statement_node.times_passed == 0 and statement_document.author == current_user) or
         (statement_node.times_passed == 1 and statement_node.supported?(current_user))))

      link_to(incorporate_proposal_path(statement_node),
             :id => 'incorporate_link',
             :class => 'ajax') do
         content_tag(:span, '',
              :class => "incorporate_statement_button_mid ttLink no_border",
              :title => I18n.t("discuss.tooltips.incorporate"))
      end
    end
  end
end