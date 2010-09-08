module StatementHelper

  def self.included(base)
    base.instance_eval do
      alias_method :proposal_path, :proposal_url
      alias_method :new_proposal_path, :new_proposal_url
      alias_method :new_translation_proposal_path, :new_translation_proposal_url

      alias_method :improvement_proposal_path, :improvement_proposal_url
      alias_method :new_improvement_proposal_path, :new_improvement_proposal_url
      alias_method :new_translation_improvement_proposal_path, :new_translation_improvement_proposal_url
    end
  end

  ########
  # URLs #
  ########

  def new_child_statement_node_url(parent, type)
    send("new_#{type.downcase}_url",parent)
  end

  def edit_statement_node_path(statement_node, opts={})
    send("edit_#{statement_node_class_dom_id(statement_node).downcase}_url",statement_node,opts)
  end

  def new_translation_url (parent, type, opts={})
    send("new_translation_#{type.downcase}_url",parent,opts)
  end

  def create_translation_url (parent, type)
    send("create_translation_#{type.downcase}_url",parent)
  end

  # returns the path to a statement_node, according to its type
  def statement_node_path(statement_node)
    statement_node = StatementNode.find(statement_node) if statement_node.kind_of?(Integer)
    send("#{statement_node_class_dom_id(statement_node).downcase}_url", statement_node)
  end

  ## Proposal

  def proposal_url(proposal)
    question_proposal_url(proposal.parent,proposal)
  end

  def new_proposal_url(parent)
    new_question_proposal_url(parent)
  end

  def edit_proposal_url(proposal,opts={})
    edit_question_proposal_url(proposal.parent, proposal,opts)
  end

  def edit_proposal_path(proposal,opts={})
    edit_question_proposal_path(proposal.parent, proposal,opts)
  end

  def new_translation_proposal_url(proposal, opts={})
    new_translation_question_proposal_url(proposal.parent, proposal,opts)
  end

  def new_translation_proposal_path(proposal, opts={})
    new_translation_question_proposal_path(proposal.parent, proposal, opts)
  end

  def create_translation_proposal_url(proposal)
    create_translation_question_proposal_url(proposal.parent, proposal)
  end

  def create_translation_proposal_path(proposal)
    create_translation_question_proposal_path(proposal.parent, proposal)
  end

  ## ImprovementProposal

  def improvement_proposal_url(improvement_proposal)
    question_proposal_improvement_proposal_url(improvement_proposal.root,
                                               improvement_proposal.parent,
                                               improvement_proposal)
  end

  def new_improvement_proposal_url(parent)
    raise ArgumentError.new("Expected `parent' to be a Proposal (is: #{parent})") unless parent.kind_of?(Proposal)
    raise ArgumentError.new("Expected `parent.parent' to be a Question (is: #{parent.parent})") unless parent.parent.kind_of?(Question)
    new_question_proposal_improvement_proposal_url(parent.parent, parent)
  end

  def edit_improvement_proposal_url(improvement_proposal,opts={})
    edit_question_proposal_improvement_proposal_url(improvement_proposal.root,
                                                    improvement_proposal.parent,
                                                    improvement_proposal,opts)
  end

  def edit_improvement_proposal_path(improvement_proposal,opts={})
    edit_question_proposal_improvement_proposal_path(improvement_proposal.root,
                                                     improvement_proposal.parent,
                                                     improvement_proposal,opts)
  end

  def new_translation_improvement_proposal_url(improvement_proposal, opts={})
    new_translation_question_proposal_improvement_proposal_url(improvement_proposal.root,
                                                               improvement_proposal.parent,
                                                               improvement_proposal, opts)
  end

  def new_translation_improvement_proposal_path(improvement_proposal, opts={})
    new_translation_question_proposal_improvement_proposal_path(improvement_proposal.root,
                                                                improvement_proposal.parent,
                                                                improvement_proposal, opts)
  end

  def create_translation_improvement_proposal_url(improvement_proposal)
    create_translation_question_proposal_improvement_proposal_url(improvement_proposal.root,
                                                                  improvement_proposal.parent,
                                                                  improvement_proposal)
  end

  def create_translation_improvement_proposal_path(improvement_proposal)
    create_translation_question_proposal_improvement_proposal_path(improvement_proposal.root,
                                                                   improvement_proposal.parent,
                                                                   improvement_proposal)
  end



  #########
  # Links #
  #########

  #
  # Creates a link to create a new child statement for the given statement
  # (appears INSIDE of the children statements panel).
  #
  def create_new_child_statement_link(statement_node)
    return unless statement_node.class.expected_children.any?
    type = statement_node_class_dom_id(statement_node.class.expected_children.first)

    link_to(I18n.t("discuss.statements.create_#{type}_link"),
            new_child_statement_node_url(statement_node, type),
            :id => "create_#{type}_link",
            :class => "ajax add_new_button text_button create_#{type}_button ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_#{type}"))
  end

  #
  # Creates a link to create a new sibling statement for the given statement (appears in the SIDEBAR).
  #
  def create_new_sibling_statement_button(statement_node)
    type = statement_node_class_dom_id(statement_node)

    link_to(new_child_statement_node_url(statement_node.parent, type),
            :id => "create_#{type}_link",
            :class => "ajax") do
      content_tag(:span, '',
                  :class => "create_statement_button_mid create_#{type}_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_#{type}"))

    end
  end

  def create_translate_statement_link(statement_node, statement_document, css_class = "")
     type = statement_node_class_dom_id(statement_node)
     link_to I18n.t('discuss.translation_request'),
              new_translation_url(statement_node, type, :current_document_id => statement_document.id),
              :class => "ajax translation_link #{css_class}"
  end

  def create_question_link_for(category=nil)
    link_to(hash_for_new_question_path.merge({:category => category}),
            :id => 'create_question_link') do
      content_tag(:span, '',
                  :class => "new_question create_statement_button_mid create_question_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_question"))
    end
  end

  def edit_statement_node_link(statement_node, statement_document)
    if current_user and
       (current_user.may_edit? or
       (statement_node.authors.include?(current_user) and !statement_node.published?))
      link_to(I18n.t('application.general.edit'), edit_statement_node_path(statement_node,:current_document_id => statement_document.id),
              :class => 'ajax header_button text_button edit_text_button')
    end
  end

  # Returns the block heading for the children of the given statement_node
  def children_box_title(statement_node)
    type = statement_node_class_dom_id(statement_node.class.expected_children.first)
    I18n.t("discuss.statements.headings.#{type}")
  end

  # Returns the block heading for entering a new child for the given statement_node
  def children_new_box_title(statement_node)
    type = statement_node_class_dom_id(statement_node)
    I18n.t("discuss.statements.new.#{type}")
  end

  def cancel_new_statement_node(statement_node,cancel_js=false)
    type = statement_node_class_dom_id(statement_node).downcase
      if type == 'question' and !cancel_js
        link_to I18n.t('application.general.cancel'),
                :back,
                :class => 'text_button bold_cancel_text_button'
      else
        link_to I18n.t('application.general.cancel'),
                session[:last_statement_node] ?
                  statement_node_path(session[:last_statement_node]) : (statement_node.parent or discuss_url),
                :class => 'ajax text_button bold_cancel_text_button'

      end
  end

  def cancel_edit_statement_node(statement_node, locked_at)
    type = statement_node_class_dom_id(statement_node).downcase.pluralize
    link_to I18n.t('application.general.cancel'),
            { :controller => type,
              :action => :cancel,
              :locked_at => locked_at.to_s },
           :class => "text_button bold_cancel_text_button ajax"
  end


  ##############
  # Sugar & UI #
  ##############

  def statement_form_illustration(statement_node)
    image_tag("page/discuss/add_#{statement_node.class.name.underscore}_big.png",
              :class => 'statement_form_illustration')
  end

  # returns the right icon for a statement_node, determined from statement_node class and given size
  def statement_node_icon(statement_node, size = :medium)
    # remove me to have different sizes again
    image_tag("page/discuss/#{statement_node_class_dom_id(statement_node)}_#{size.to_s}.png")
  end

  # inserts a status bar based on the support ratio  value
  # (support ratio is the calculated ratio for a statement_node,
  # representing and visualizing the agreement a statement_node has found within the community)
  def supporter_ratio_bar(statement_node,context=nil)
    if statement_node.supporter_count < 2
      tooltip = I18n.t('discuss.tooltips.echo_indicator.one',
                       :supporter_count => statement_node.supporter_count)
    else
      tooltip = I18n.t('discuss.tooltips.echo_indicator.many',
                       :supporter_count => statement_node.supporter_count)
    end
    if statement_node.ratio > 1
      val = "<span class='echo_indicator ttLink' title='#{tooltip}' alt='#{statement_node.ratio}'></span>"
    else
      val = "<span class='no_echo_indicator ttLink' title='#{tooltip}'></span>"
    end
  end

  # Renders the button for echo and unecho.
  def render_echo_button(url_options, echo = true)
    title = I18n.t("discuss.tooltips.#{echo ? '' : 'un'}echo")
    link_to(url_for(url_options.merge({:action => (echo ? :echo : :unecho)})),
                    :class => "ajax_put",
                    :id => 'echo_button') do
      "<span class='#{echo ? 'not_' : '' }supported ttLink no_border' title='#{title}'></span>"
    end
  end

  # Returns the context menu link for this statement_node.
  def statement_node_context_link(statement_node, language_ids, action = 'read', last_statement_node = false)
    return if (statement_document = statement_node.document_in_preferred_language(language_ids)).nil?
    link = link_to(h(statement_document.title),
                   url_for(statement_node),
                   :class => "ajax no_border statement_link #{statement_node.class.name.underscore}_link ttLink",
                   :title => I18n.t("discuss.tooltips.#{action}_#{statement_node.class.name.underscore}"))
    if !statement_node.echoable?
      link << echo_label unless last_statement_node
    else
      link << supporter_ratio_bar(statement_node,'context')
    end
    return link
  end


  # Creates a label to explain the echo/supporter count indicators
  def echo_label(context=nil)
    val = "<span class='echo_label'>#{I18n.t('discuss.statements.label')}</span>"
  end


  ##############
  # Navigation #
  ##############

  # Insert prev/next buttons for the current statement_node.
  def prev_next_buttons(statement_node)
    type = statement_node.class.to_s.underscore
    key = ("current_" + type).to_sym
    if session[key].present? and session[key].include?(statement_node.id)
      index = session[key].index(statement_node.id)
      buttons = if session[key].length == 1
                  statement_tag(:prev, type, true)
                elsif index == 0
                  statement_button(session[key][session[key].length-1], statement_tag(:prev, type), :rel => 'prev')
                else
                  statement_button(session[key][index-1], statement_tag(:prev, type), :rel => 'prev')
                end
      buttons << if session[key].length == 1
                   statement_tag(:next, type, true)
                 elsif index == session[key].length-1
                   statement_button(session[key][0], statement_tag(:next, type), :rel => 'next')
                 else
                   statement_button(session[key][index+1], statement_tag(:next, type), :rel => 'next')
                 end
    end
  end

  def statement_tag(direction, class_identifier, disabled=false)
    if !disabled
      content_tag(:span, '&nbsp;',
                  :class => "#{direction}_stmt ttLink no_border",
                  :title => I18n.t("discuss.tooltips.#{direction}_#{class_identifier}"))
    else
      content_tag(:span, '&nbsp;',
                  :class => "#{direction}_stmt disabled")
    end
  end

  # Insert a button that links to the previous statement_node
  # TODO AR from the helper stinks, but who knows a better way to get the right url?
  # maybe one could code some statement_node.url method..?
  def statement_button(id, title, options={})
    stmt = StatementNode.find(id)
    options[:class] ||= ''
    options[:class] += ' ajax'
    return link_to(title, url_for(stmt), options)
  end


  ##################
  # DOM-ID Helpers #
  ##################

  # returns the statement_node class dom identifier (used to identifiy dom objects, e.g. for javascript)
  def statement_node_class_dom_id(statement_node)
    if statement_node.kind_of?(Symbol)
      statement_node_class = statement_node.to_s.constantize
     elsif statement_node.kind_of?(StatementNode)
      statement_node_class = statement_node.class
    end
    statement_node_class.name.underscore.downcase
  end

  # returns the dom identifier for a particular statement_node
  # consisting out of the statement_node class dom identifier, and the statement_nodes id
  def statement_node_dom_id(statement_node)
    "#{statement_node_class_dom_id(statement_node)}_#{statement_node.id}"
  end

  def link_to_child(title,statement_node,extra_classes)
    link_to h(title),
            url_for(statement_node),
            :class => "ajax statement_link #{statement_node.class.name.underscore}_link #{extra_classes} ttLink no_border",
            :title => I18n.t("discuss.tooltips.read_#{statement_node.class.name.underscore}")
  end

  def translation_upper_box(language_from, language_to)
    val = "#{image_tag 'page/translation/babelfish_left.png', :class => 'fish_left'}"
    val << %(<span class="language_label from_language"> #{language_from} </span>)
    val << "#{image_tag 'page/translation/translation_arrow.png',:class => 'arrow'}"
    val << "#{image_tag 'page/translation/babelfish_right.png', :class => 'fish_right'}"
    val << %(<span class="language_label to_language">#{language_to}</span>)
    val
  end

end
