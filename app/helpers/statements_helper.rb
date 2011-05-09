module StatementsHelper

  include PublishableModuleHelper
  include EchoableModuleHelper
  include IncorporationModuleHelper
  include TranslationModuleHelper


  ##################
  # RENDER HELPERS #
  ##################

  #
  # Renders ancestors headers (when we have a GET operation on a child node).
  #
  def render_ancestors(ancestors, ancestor_documents)
    val = ''
    ancestors.each do |ancestor|
      val << render_ancestor(ancestor, ancestor_documents[ancestor.statement_id])
    end
    val
  end

  def render_ancestor(ancestor, document)
    render :partial => 'statements/show', :locals => {:statement_node => ancestor,
                                                      :statement_document => document,
                                                      :only_header => true}
  end

  #
  # Renders all the possible children of the current node
  # (per type, ordering must be defined in the node type definition).
  #
  def render_children(statement_node, children, type = dom_class(statement_node))
    return content_tag :div, '', :style => "clear:right" if children.blank?
    val = ''
    statement_node.class.children_types.each do |child_type|
      dom_child_class = child_type.to_s.underscore
      arg = children[child_type]
      if (arg.kind_of?(Integer))
        type_children = children_statement_node_url(statement_node, :type => dom_child_class)
        count = arg
      else
        type_children = arg
        count = child_type.to_s.constantize.double? ? type_children.map(&:total_entries).sum : type_children.total_entries
      end
      val << render(:partial => 'statements/children',
                    :locals => {:type => dom_child_class,
                                :count => count,
                                :children => type_children})
    end
    val
  end


  #########
  # Links #
  #########

  #
  # Creates a link to create a new child statement of a given type for the current statement
  # (appears INSIDE of the children statements panel).
  #
  def create_new_child_statement_link(statement_node, child_type, opts={})
    url = opts.delete(:url) if opts[:url]
    css = opts.delete(:css) if opts[:css]
    link_to(I18n.t("discuss.statements.create_#{child_type}_link"),
            url ? url : new_statement_node_url(statement_node.nil? ? nil : statement_node.target_id,child_type, opts),
            :class => "#{css} add_new_button text_button create_#{child_type}_button ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_#{child_type}"))
  end

  def create_new_question_link(origin=@origin, opts={})
    type = 'question'
    parent = nil
    if !origin.blank?
      key = origin[0, 2]
      parent = case key
        when 'ds', 'sr', 'mi' then nil
        when 'fq' then type = 'follow_up_question'
                       origin[2..-1]
      end
    end
    url = parent.nil? ? new_question_url(:bids => origin, :origin => origin) : new_statement_node_url(parent, type)
    create_new_child_statement_link(parent, type, opts.merge({:url => url}))
  end


  #
  # Creates a link to add a new resource for the given statement (appears in the SIDEBAR).
  #
  def render_add_new_button(statement_node, origin = nil, bids = nil)
    content = ''
    content << content_tag(:div, :class => 'add_new_button') do
      button = ''
      button << content_tag(:span, '', :class => 'add_new_button_icon')
      button << content_tag(:span, I18n.t('discuss.statements.add_new'),
                            :class => 'label')
      button
    end
    content << content_tag(:div, :class => 'add_new_panel popup_panel',
                           :style => "display:none") do
      panel = ''
      panel << content_tag(:div, :class => 'panel_header') do
        I18n.t("discuss.statements.add_new")
      end
      panel << content_tag(:div, '', :class => 'block_separator')
      panel << add_new_sibling_buttons(statement_node, origin)
      panel << add_new_child_buttons(statement_node)
      panel << add_new_follow_up_question_button(statement_node, bids)
      panel
    end
  end

  #
  # Creates a link to add a new sibling for the given statement (appears in the SIDEBAR).
  #
  def add_new_sibling_buttons(statement_node, origin = nil, type = dom_class(statement_node))
    content = ''
    content << content_tag(:div, :class => 'siblings container') do
      if statement_node.parent
        add_new_sibling_button(statement_node)
      else
        if origin.blank? or %w(ds mi sr).include? origin[0,2] # create new question
          add_new_question_button(!origin.blank? ? origin : nil)
        else #create sibling follow up question
          context_type = ''
          context_type << case origin[0,2]
            when 'fq' then "follow_up_question"
          end

          link_to(I18n.t("discuss.statements.siblings.#{context_type}"),
                new_statement_node_url(origin[2..-1], context_type, :origin => origin),
                :class => "create_#{context_type}_button_32 resource_link ajax")
        end
      end
    end
    content << content_tag(:div, '', :class => 'block_separator')
    content
  end

  #
  # Creates a link to add a new sibling for the given statement (appears in the SIDEBAR).
  #
  def add_new_sibling_button(statement_node)
    content = ''
    statement_node.class.sub_types.map.each do |sub_type|
      sub_type = sub_type.to_s.underscore
      content << link_to(I18n.t("discuss.statements.types.#{sub_type}"),
                         new_statement_node_url(statement_node.parent, sub_type),
                         :class => "create_#{sub_type}_button_32 resource_link ajax")
    end
    content
  end

  #
  # Creates a link to add a new child for the given statement (appears in the SIDEBAR).
  #
  def add_new_child_buttons(statement_node)
    children_types = statement_node.class.children_types(:no_default => true, :expand => true)
    return '' if children_types.empty?
    content = ''
    content << content_tag(:div, :class => 'children container') do
      children = ''
      children_types.each do |type|
        children << add_new_child_link(statement_node, type.to_s.underscore)
      end
      children
    end
    content << content_tag(:div, '', :class => 'block_separator')
    content
  end

  #
  # Creates a link to add a new follow up question for the given statement (appears in the SIDEBAR).
  #
  def add_new_follow_up_question_button(statement_node, bids)
    bids = bids ? bids.split(",") : []
    bids << "fq#{statement_node.id}"
    content_tag(:div, add_new_child_link(statement_node, "follow_up_question",
                                                         :bids => bids.join(","),
                                                         :origin => params[:origin]),
                :class => 'children container')
  end

  #
  # Returns a link to create a new child statement from a given type for the given statement (appears in the SIDEBAR).
  #
  def add_new_child_link(statement_node, type, opts={})
    opts[:new_level] = true
    link_to(I18n.t("discuss.statements.types.#{type}"),
            new_statement_node_url(statement_node, type, opts),
            :class => "create_#{type}_button_32 resource_link ajax")
  end

  #
  # Creates a link to edit the current document.
  #
  def edit_statement_node_link(statement_node, statement_document)
    if current_user and current_user.may_edit?(statement_node)
      link_to(I18n.t('application.general.edit'), edit_statement_node_url(statement_node, :current_document_id => statement_document.id),
              :class => 'ajax header_button text_button edit_text_button')
    else
      ''
    end
  end

  #
  # Creates a link to show the authors of the current node.
  #
  def authors_statement_node_link(statement_node,type = dom_class(statement_node))
    link_to(I18n.t('application.general.authors'), authors_statement_node_url(statement_node),
            :class => 'expandable header_button text_button authors_text_button')
  end

  #
  # Render the list of authors.
  #
  def render_authors(statement_node, user, authors)
    content_tag(:ul, :class => 'authors_list') do
      content = ''
      content << render(:partial => 'statements/author', :collection => authors)
      content << author_teaser(statement_node, user) if statement_node.draftable? and !authors.include?(user)
      content
    end
  end

  #
  # Creates a teaser for authors with author styling.
  #
  def author_teaser(statement_node, user)
    content_tag :li, :class => 'author teaser' do
      content = ''
      content << image_tag(user.avatar.url(:small), :alt => '')
      content << content_tag(:span, I18n.t('users.authors.teaser.title'), :class => 'name')
      content << create_new_child_statement_link(statement_node, 'improvement', :new_level => true, :css => "ajax")
      content
    end
  end

  #
  # Creates a link to delete the current statement.
  #
  def delete_statement_node_link(statement_node)
    link_to I18n.t('discuss.statements.delete_link'),
            statement_node_url(statement_node),
            :class => 'admin_action',
            :method => :delete,
            :confirm => I18n.t('discuss.statements.delete_confirmation')
  end

  #
  # Loads the function buttons of the current statement (edit, authors).
  #
  def function_buttons(statement_node, statement_document)
    val = ''
    val << edit_statement_node_link(statement_node, statement_document)
    val << publish_statement_node_link(statement_node, statement_document) if statement_node.publishable?
    val << authors_statement_node_link(statement_node)
    content_tag :span, val, :class => 'action_buttons'
  end

  #
  # Returns the block heading for entering a new child for the given statement node.
  #
  def children_new_box_title(statement_node)
    I18n.t("discuss.statements.new.#{dom_class(statement_node)}")
  end

  #
  # Returns the block heading for the children of the current statement node.
  #
  def children_heading_title(type, count)
    title = ''
    title << I18n.t("discuss.statements.headings.#{type}")
    title << content_tag(:span, " (#{count})", :class => 'count')   # ·
    title
  end

  #
  # Returns the block heading for the siblings of the current statement node.
  #
  def sibling_box_title(type)
    content_tag :span, I18n.t("discuss.statements.headings.#{type}"), :class => 'label'
  end

  #
  # Creates the cancel button in the new statement form (right link will be handled in jquery).
  #
  def cancel_new_statement_node(cancel_js=false)
    link_to I18n.t('application.general.cancel'),
            :back,
            :class => 'cancel text_button cancel_text_button'
  end

  #
  # Creates the cancel button in the edit statement form.
  #
  def cancel_edit_statement_node(statement_node, locked_at,type = dom_class(statement_node))
    link_to I18n.t('application.general.cancel'),
            cancel_statement_node_url(statement_node, :locked_at => locked_at.to_s),
           :class => "text_button cancel_text_button ajax"
  end

  def title_hint_text(statement_node)
    I18n.t("discuss.statements.title_hint.#{dom_class(statement_node)}")
  end

  def summary_hint_text(statement_node)
    I18n.t("discuss.statements.text_hint.#{dom_class(statement_node)}")
  end

  ##############
  # Sugar & UI #
  ##############

  #
  # Loads the right add statement image.
  #
  def statement_form_illustration(statement_node)
    image_tag("page/discuss/add_#{dom_class(statement_node)}_big.png",
              :class => 'statement_form_illustration')
  end

  #
  # Returns the right icon for a statement_node, determined from statement_node class and given size.
  #
  def statement_node_icon(statement_node, size = :medium)
    # remove me to have different sizes again
    image_tag("page/discuss/#{dom_class(statement_node)}_#{size.to_s}.png")
  end

  #
  # Returns the context menu link for this statement_node.
  #
  def statement_node_context_link(statement_node, title, action = 'read', opts={})
    css = opts.delete(:css)
    link_to(h(title),
             statement_node_url(statement_node, opts),
             :class => "#{css} no_border statement_link #{dom_class(statement_node)}_link ttLink",
             :title => I18n.t("discuss.tooltips.#{action}_#{dom_class(statement_node)}"))
  end

  #
  # Render the hint on the new statement forms for users with no spoken language defined.
  #
  def define_languages_hint
    content_tag :p, I18n.t('discuss.statements.statement_language_hint', :url => my_profile_url),
                :class => 'ttLink no_border',
                :title => I18n.t('discuss.statements.statement_language_hint_tooltip')
  end

  #
  # Render the hint on the new draftable statement forms to warn about drafting language on collective text creation.
  #
  def drafting_language_hint
    content_tag :p, I18n.t('discuss.statements.drafting_language_hint')
  end

  def top_statement_hint
    content_tag :p, I18n.t("discuss.statements.fuq_formulation_hint")
  end

  #
  # Render the hint on the edit statement forms to warn about the time the users have to edit it.
  #
  def edit_period_hint
    content = ''
    content << content_tag(:li, :class => 'hint') do
      content_tag :p, I18n.t('discuss.statements.edit_period_hint', :minutes => 60)
    end
    content
  end


  ##############
  # Navigation #
  ##############

  #
  # Renders prev/next/siblings buttons for the current statement_node.
  #
  def navigation_buttons(statement_node, type, opts={})
    buttons = ''
    if statement_node and statement_node.new_record?
      %w(prev next).each{|button| buttons << statement_tag(button.to_sym, type, true)}
      buttons << content_tag(:span,
                             I18n.t("discuss.statements.sibling_labels.#{type.classify.constantize.name_for_siblings}"), 
                             :class => 'show_siblings_label disabled')
    else
      buttons << content_tag(:span, '', :class => 'loading', :style => 'display:none')
      %w(prev next).each do |button|
        buttons << statement_button(statement_node,
                                    statement_tag(button.to_sym, type),
                                    type,
                                    :rel => button,
                                    :class => " statement_link #{opts[:classes]} #{button}")
      end
      buttons << siblings_button(statement_node, type, opts)
    end
    buttons
  end

  def siblings_button(statement_node, type, opts={})
    origin = opts[:origin]
    name = type.classify.constantize.name_for_siblings
    url = if statement_node.nil? or statement_node.class.name.underscore != type # ADD TEASERS
      if statement_node.nil?
        question_descendants_url(:origin => origin)
      else
        descendants_statement_node_url(statement_node, name)
      end
    else  # STATEMENT NODES
      if statement_node.parent_id.nil?
        question_descendants_url(:origin => origin, :current_node => statement_node)
      else
        descendants_statement_node_url(statement_node.parent,
                                       statement_node.class.name_for_siblings,
                                       :current_node => statement_node)
      end
    end

    content_tag(:a,
                :href => url,
                :class => 'show_siblings_button expandable') do
      content_tag(:span, I18n.t("discuss.statements.sibling_labels.#{name}"),
                  :class => 'show_siblings_label ttLink no_border',
                  :title => I18n.t("discuss.tooltips.siblings.#{statement_node ? dom_class(statement_node) : 'question'}"))
    end
  end

  #
  # Renders the correct prev/next image buttons.
  #
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

  #
  # Inserts a button that links to the previous statement_node.  #
  # IMP NOTE: siblings always include the teaser at the end, so always be careful when handling it
  #
  def statement_button(statement_node, title, type, options={})
    options[:class] ||= ''
    teaser = options[:class].include? 'add'
    url_opts = {:origin => params[:origin], :bids => params[:bids]}
    # if prev/next for teaser
    unless @siblings.nil?
      if teaser
        if (siblings = @siblings["add_#{@type}"])
          element_index = siblings.index { |s| s =~ /#{@type}/ }
        end
      else # if prev/next for statement
        if (siblings = @siblings[dom_id(statement_node)])
          element_index = siblings.index(statement_node.id)
        end
      end
      unless siblings.nil?
        element_index = 0 if element_index.nil?
        index = element_index
        if options[:rel].eql? 'prev'
          index = element_index - 1
        elsif options[:rel].eql? 'next'
          index = element_index + 1
        end
        index = index < 0 ? (siblings.length - 1) : (index >= siblings.length ? 0 : index )

        url = !(siblings[index].to_s =~ /add/).nil? ? add_teaser_statement_node_path(statement_node,url_opts) :
                                                      statement_node_url(siblings[index], url_opts)
      end
    else
      url = add_teaser_statement_node_path(statement_node)
    end
    options['data-id'] =
      teaser ? "#{statement_node.nil? ? '' : "#{statement_node.id}_"}add_#{type}" : statement_node.id
    return link_to(title, url, options)
  end

  def add_teaser_statement_node_path(statement_node, opts={})
    if statement_node.nil? or statement_node.level == 0
      add_question_teaser_url(opts)
    else
      add_teaser_url(statement_node.parent, opts.merge(:type => dom_class(statement_node)))
    end
  end

  #
  # Loads the link to a given statement, placed in the child panel section.
  #
  def link_to_child(title, statement_node,extra_classes, type = dom_class(statement_node))
    bids = params[:bids] || ''
    bids = bids.split(",")
    bid = "#{Breadcrumb.instance.generate_key(type)}#{@statement_node.target_id}"
    bids << bid
    bids = bids.join(",")

    link_to h(title),
            statement_node_url(statement_node.target_id, :bids => bids, :origin => params[:origin],  :new_level => true),
            :class => "statement_link #{dom_class(statement_node)}_link #{extra_classes}"
  end

  #
  # Draws the statement image container.
  #
  def statement_image(statement_node)
    val = ""
    editable = (current_user and current_user.may_edit?(statement_node))
    if statement_node.image.exists? or editable
      val << image_tag(statement_node.image.url(:medium), :class => 'image')
      if editable
        val << link_to(I18n.t('users.profile.picture.upload_button'),
                       edit_statement_image_url(statement_node.statement_image, statement_node),
                       :class => 'ajax upload_link button button_150')
      end
    end
    content_tag :div, val, :class => "image_container #{editable ? 'editable' : ''}" if !val.blank?
  end

  #
  # Renders the "more" link when the statement is loaded.
  #
  def more_children(statement_node,type,page=0)
    link_to I18n.t("application.general.more"),
            more_statement_node_url(statement_node, :page => page.to_i+1, :type => type),
            :class => 'more_children ajax'
  end


  ###############
  # BREADCRUMBS #
  ###############

  #
  # Renders the given breadcrumbs.
  #
  def render_breadcrumb(breadcrumbs)
    breadcrumb_trail = ""
    breadcrumbs.each_with_index do |b, index| #[id, classes, url, title]
      attrs = {}
      attrs[:page_count] = b[:page_count] if b[:page_count]
      breadcrumb = content_tag(:a, attrs.merge({:href => b[:url], :id => b[:key], :class => 'breadcrumb'})) do
        content = ""
        content << content_tag(:span, '', :class => 'big_delimiter') if index != 0
        content << content_tag(:span, b[:label], :class => 'label')
        content << content_tag(:span, b[:over], :class => 'over')
        content << content_tag(:span, h(Breadcrumb.instance.decode_terms(b[:title])), :class => b[:css])
        content
      end
      breadcrumb_trail << breadcrumb
    end
    breadcrumb_trail
  end

  #
  # This class does the heavy lifting of actually building the pagination links.
  # It is used by the <tt>will_paginate</tt> helper internally.
  #
  class MoreRenderer < WillPaginate::LinkRenderer
    def to_html
      html = page_link_or_span(@collection.next_page, 'disabled more_children', @options[:next_label])
      html = html.html_safe if html.respond_to? :html_safe
      @options[:container] ? @template.content_tag(:div, html, html_attributes) : html
    end
  end

end

