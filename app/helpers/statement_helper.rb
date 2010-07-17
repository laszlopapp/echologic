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

  ##
  ## URLS
  ##

  def new_child_statement_node_url(parent, type)
    case type.downcase
    when 'question'
      new_question_url(parent)
    when 'proposal'
      new_proposal_url(parent)
    when 'improvement_proposal'
      new_improvement_proposal_url(parent)
    when 'pro_argument'
      new_pro_argument_proposal_url(parent)
    else
      raise ArgumentError.new("Unhandled type: #{type.downcase}")
    end
  end

  def edit_statement_node_path(statement_node)
    case statement_node_class_dom_id(statement_node).downcase
    when 'question'
      edit_question_path(statement_node)
    when 'proposal'
      edit_proposal_path(statement_node)
    when 'improvement_proposal'
      edit_improvement_proposal_path(statement_node)
    else
      raise ArgumentError.new("Unhandled type: #{statement_node_dom_id(statement_node).downcase}")
    end
  end

  def new_translation_url (parent, type)
    case type.downcase
    when 'question'
      new_translation_question_url(parent)
    when 'proposal'
      new_translation_proposal_url(parent)
    when 'improvement_proposal'
      new_translation_improvement_proposal_url(parent)
    when 'pro_argument'
      new_translation_pro_argument_proposal_url(parent)
    else
      raise ArgumentError.new("Unhandled type: #{type.downcase}")
    end
  end

  def create_translation_url (parent, type)
    case type.downcase
    when 'question'
      create_translation_question_url(parent)
    when 'proposal'
      create_translation_proposal_url(parent)
    when 'improvement_proposal'
      create_translation_improvement_proposal_url(parent)
    when 'pro_argument'
      create_translation_pro_argument_proposal_url(parent)
    else
      raise ArgumentError.new("Unhandled type: #{type.downcase}")
    end
  end

  # returns the path to a statement_node, according to its type
  def statement_node_path(statement_node)
    statement_node = StatementNode.find(statement_node) if statement_node.kind_of?(Integer)
    case statement_node_class_dom_id(statement_node).downcase
    when 'question'
      question_url(statement_node)
    when 'proposal'
      proposal_url(statement_node)
    when 'improvement_proposal'
      improvement_proposal_url(statement_node)
    else
      raise ArgumentError.new("Unhandled type: #{statement_node_dom_id(statement_node).downcase}")
    end
  end

  ## Proposal

  def proposal_url(proposal)
    question_proposal_url(proposal.parent,proposal)
  end

  def new_proposal_url(parent)
    new_question_proposal_url(parent)
  end

  def edit_proposal_url(proposal)
    edit_question_proposal_url(proposal.parent, proposal)
  end

  def edit_proposal_path(proposal)
    edit_question_proposal_path(proposal.parent, proposal)
  end

  def new_translation_proposal_url(proposal)
    new_translation_question_proposal_url(proposal.parent, proposal)
  end

  def new_translation_proposal_path(proposal)
    new_translation_question_proposal_path(proposal.parent, proposal)
  end

  def create_translation_proposal_url(proposal)
    create_translation_question_proposal_url(proposal.parent, proposal)
  end

  def create_translation_proposal_path(proposal)
    create_translation_question_proposal_path(proposal.parent, proposal)
  end

  ## ImprovementProposal

  def improvement_proposal_url(proposal)
    question_proposal_improvement_proposal_url(proposal.root, proposal.parent, proposal)
  end

  def new_improvement_proposal_url(parent)
    raise ArgumentError.new("Expected `parent' to be a Proposal (is: #{parent})") unless parent.kind_of?(Proposal)
    raise ArgumentError.new("Expected `parent.parent' to be a Question (is: #{parent.parent})") unless parent.parent.kind_of?(Question)
    new_question_proposal_improvement_proposal_url(parent.parent, parent)
  end

  def edit_improvement_proposal_url(proposal)
    edit_question_proposal_improvement_proposal_url(proposal.root, proposal.parent, proposal)
  end

  def edit_improvement_proposal_path(proposal)
    edit_question_proposal_improvement_proposal_path(proposal.root, proposal.parent, proposal)
  end

  def new_translation_improvement_proposal_url(proposal)
    new_translation_question_proposal_improvement_proposal_url(proposal.root, proposal.parent, proposal)
  end

  def new_translation_improvement_proposal_path(proposal)
    new_translation_question_proposal_improvement_proposal_path(proposal.root, proposal.parent, proposal)
  end

  def create_translation_improvement_proposal_url(proposal)
    create_translation_question_proposal_improvement_proposal_url(proposal.root, proposal.parent, proposal)
  end

  def create_translation_improvement_proposal_path(proposal)
    create_translation_question_proposal_improvement_proposal_path(proposal.root, proposal.parent, proposal)
  end

  ##
  ## LINKS
  ##

  # Creates a link to create a new child item for a Statement
  def create_new_statement_button(statement_node, css_class = "", lan_tag = "", statement_node_for_image = nil)
    return unless statement_node.class.expected_children.any?
    type = statement_node_class_dom_id(statement_node.class.expected_children.first)

#    if statement_node_for_image
#      link_block = image_tag("page/discuss/add_#{statement_node_for_image.class.name.underscore}_big.png",
#                             :class => 'new_statement_button_illustration')
#      link_block << I18n.t(lan_tag.blank? ? "discuss.statements.create_#{type}_link" : "discuss.statements.#{lan_tag}")
#    else
#      link_block = I18n.t(lan_tag.blank? ? "discuss.statements.create_#{type}_link" : "discuss.statements.#{lan_tag}")
#    end

    image_class = statement_node_for_image ?
                    "create_statement_button_mid create_#{statement_node_for_image.class.name.underscore}_button_mid" :
                    "text_button create_#{type}_button"

    link_to(I18n.t(lan_tag.blank? ? "discuss.statements.create_#{type}_link" : "discuss.statements.#{lan_tag}"),
            new_child_statement_node_url(statement_node, type),
            :id => "create_#{type.underscore}_link",
            :class => "ajax #{css_class} #{image_class} ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_#{type.underscore}"))
  end

  def create_translate_statement_link(statement_node, css_class = "")
     type = statement_node_class_dom_id(statement_node)
     link_to I18n.t('discuss.translation_request'),
              new_translation_url(statement_node, type),
              :class => "ajax translation_link #{css_class}"
  end

  def create_question_link_for
    return unless current_user
    link_to(I18n.t("discuss.statements.create_question_link"),
            new_question_url,
            :class=> 'text_button create_question_button ttLink no_border')
  end

  def edit_statement_node_link(statement_node, statement_document)
    if current_user and
       (current_user.may_edit? or
       (statement_document.author == current_user and !statement_node.published?))
      link_to(I18n.t('application.general.edit'), edit_statement_node_path(statement_node),
              :class => 'ajax header_button text_button edit_text_button')
    end
  end

  def publish_statement_node_link(statement_node, statement_document)
    if current_user and
       statement_document.author == current_user and !statement_node.published?
      link_to(I18n.t('discuss.statements.publish'),
              { :controller => :questions,
                :action => :publish,
                :in => :summary },
              :class => 'ajax_put header_button text_button publish_text_button ttLink',
              :title => I18n.t('discuss.tooltips.publish'))
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

  def cancel_new_statement_node(statement_node)
    type = statement_node_class_dom_id(statement_node).downcase
      if type == 'question'
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

  ##
  ## CONVENIENCE and UI
  ##

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


  # DEPRICATED, user statement_node_context_link instead
  def statement_node_context_line(statement_node)
    link = link_to(statement_node_icon(statement_node, :small) + statement_node.title,
                   url_for(statement_node),
                   :class => 'ajax')
    link << supporter_ratio_bar(statement_node,'context') unless statement_node.class.name == 'Question'
    return link
  end

  # Returns the context menu link for this statement_node.
  def statement_node_context_link(statement_node, language_keys, action = 'read', last_statement_node = false)
    return if (statement_document = statement_node.translated_document(language_keys)).nil?
    link = link_to(statement_document.title,
                   url_for(statement_node),
                   :class => "ajax no_border statement_link #{statement_node.class.name.underscore}_link ttLink",
                   :title => I18n.t("discuss.tooltips.#{action}_#{statement_node.class.name.underscore}"))
    if statement_node.class.name == 'Question'
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

  ##
  ## Navigation within statement_nodes
  ##

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

  ##
  ## DOM-ID Helpers
  ##

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

  ###############################
  ## LANGUAGE RELATED MESSAGES
  ##############################

  def original_language_warning?(statement_node, user, language_key)
    user ? (user.spoken_languages.empty? and language_key != statement_node.statement.original_language.id) : false
  end

  def translatable?(statement_node,user,language_code,language_preference_list)
    statement_document = statement_node.translated_document(language_preference_list)
    if user
      # 1.we have a current user that speaks languages
      !user.spoken_languages.blank? and
      # 2.we ensure ourselves that the user has a mother tongue
      !user.mother_tongues.blank? and
      # 3.current text language is different from the current language,
      # which would mean there is no translated version of the document yet in the current language
      !statement_document.language.code.eql?(language_code) and
      # 4.application language is the current user's mother tongue
      user.mother_tongues.collect{|l| l.code}.include?(language_code) and
      # 5.user knows the document's language
      user.spoken_languages.map{|sp| sp.language}.uniq.include?(statement_document.language) and
      #6. user has language level greater than intermediate
      %w(intermediate advanced mother_tongue).include?(
        user.spoken_languages.select {|sp| sp.language == statement_document.language}.first.level.code)
    else
      false
    end
  end

  ##################################
  ##### FORM RENDERS
  ##################################

  def render_new_statement_node(statement_node, language_preference_list)
    render :update do |page|
      if statement_node.kind_of?(Question)
        page.remove 'search_container'
        page.remove 'new_question'
        page.replace 'questions_container', :partial => 'statements/new'
        page.replace 'my_discussions', :partial => 'statements/new'
      else
        page.replace 'children', :partial => 'statements/new'
      end
      page.replace('summary',
                   :partial => 'statements/summary',
                   :locals => { :statement_node => statement_node.parent,
                                :statement_document => statement_node.parent.
                                  translated_document(language_preference_list)}) if statement_node.parent
      page.replace('context',
                   :partial => 'statements/context',
                   :locals => { :statement_node => statement_node.parent}) if statement_node.parent
      page.replace('discuss_sidebar',
                   :partial => 'statements/sidebar',
                   :locals => { :statement_node => statement_node.parent})
      # Direct JS
      page << "makeRatiobars();"
      page << "makeTooltips();"
    end
  end

  def render_create_statement_node(statement_node,statement_document,statement_node_children)
    render_with_info do |page|
      if statement_node.kind_of?(Question)
        page.redirect_to(url_for statement_node)
      else
        page.replace('context',
                     :partial => 'statements/context',
                     :locals => { :statement_node => statement_node})
        page.replace('discuss_sidebar',
                     :partial => 'statements/sidebar',
                     :locals => { :statement_node => statement_node})
        page.replace('summary',
                     :partial => 'statements/summary',
                     :locals => { :statement_node => statement_node,
                                  :statement_document => statement_document})
        page.replace 'new_statement',
                   :partial => 'statements/children',
                   :statement => statement_node,
                   :children => statement_node_children
      end

      # Direct JS

      page << "makeRatiobars();"
      page << "makeTooltips();"
    end
  end

  def render_new_translation
    render :update do |page|
      page.replace('summary', :partial => 'statements/translate')
      page << "makeRatiobars();"
      page << "makeTooltips();"
      page << "roundCorners();"
    end
  end

  def render_create_translation(statement_node,statement_document)
    render_with_info do |page|
      page.replace('context',
                   :partial => 'statements/context',
                   :locals => { :statement_node => statement_node})
      page.replace('summary',
                   :partial => 'statements/summary',
                   :locals => { :statement_node => statement_node,
                                :statement_document => statement_document})
      page << "makeRatiobars();"
      page << "makeTooltips();"
    end
  end

  ###############################
  #### TAGS
  ###############################

  def check_tag_permissions(statement_node)
    statement_node.tao_tags.each do |tao_tag|
      index = tao_tag.tag.value.index '#'
      if !index.nil? and index == 0 and !current_user.has_role? :topic_editor, tao_tag.tag
        set_error('discuss.tag_permission', :tag => tao_tag.tag.value)
      end
    end
  end
end
