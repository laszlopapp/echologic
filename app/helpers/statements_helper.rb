module StatementsHelper
  include PublishableModuleHelper
  include EchoableModuleHelper
  include IncorporationModuleHelper
  include TranslationModuleHelper

  ##################
  # RENDER HELPERS #
  ##################

  # Renders ancestors headers (when we have a GET operation on a child node)
  def render_ancestors(ancestors)
    val = ''
    ancestors.each do |ancestor|
      val << render_ancestor(ancestor)
    end
    val
  end

  def render_ancestor(ancestor)
    render :partial => 'statements/show', :locals => {:statement_node => ancestor, :only_header => true}
  end

  # Renders all the possible children of the current node (per type, ordering must be defined in the node type definition)
  def render_children(statement_node, children, type = dom_class(statement_node))
    return content_tag :div, '', :style => "clear:right" if children.blank?
    val = ''
    statement_node.class.children_types.each do |child_type|
      dom_child_class = child_type.to_s.underscore
      type_children = children[child_type] || children_statement_node_url(statement_node, :type => dom_child_class)
      val << render(:partial => 'statements/children', :locals => {:type => dom_child_class, :children => type_children})
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
    opts[:new_level] ||= true
    url = opts.delete(:url) if opts[:url]
    link_to(I18n.t("discuss.statements.create_#{child_type}_link"),
            url ? url : new_statement_node_url(statement_node.nil? ? nil : statement_node.target_id,child_type, opts),
            :id => "create_#{child_type}_link",
            :class => "ajax add_new_button text_button create_#{child_type}_button ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_#{child_type}"))
  end

  def create_new_question_link(origin)
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
    url = parent.nil? ? new_question_url(:origin => origin) : new_statement_node_url(parent, type)
    create_new_child_statement_link(parent, type, :url => url)
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

          link_to(I18n.t("discuss.statements.types.#{context_type}"),
                new_statement_node_url(origin[2..-1], context_type),
                :id => "add_new_#{context_type}_link", :class => "#{context_type}_link resource_link ajax")
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
                         :id => "add_new_#{sub_type}_link", :class => "#{sub_type}_link resource_link ajax")
    end
    content
  end

  #
  # Creates a link to add a new child for the given statement (appears in the SIDEBAR).
  #
  def add_new_child_buttons(statement_node)
    children_types = statement_node.class.children_types(false, false, true)
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
    content_tag(:div, add_new_child_link(statement_node, "follow_up_question", :bids => bids.join(",")), :class => 'children container')
  end

  #
  # Returns a link to create a new child statement from a given type for the given statement (appears in the SIDEBAR).
  #
  def add_new_child_link(statement_node, type, opts={})
    opts[:new_level] = true
    link_to(I18n.t("discuss.statements.types.#{type}"),
            new_statement_node_url(statement_node, type, opts),
            :id => "add_new_#{type}_link", :class => "#{type}_link resource_link ajax")
  end

  #
  # Creates a link to edit the current document.
  #
  def edit_statement_node_link(statement_node, statement_document)
    if current_user and
       (current_user.may_edit? or
       (statement_node.authors.include?(current_user) and !statement_node.published?))
      link_to(I18n.t('application.general.edit'), edit_statement_node_url(statement_node, :current_document_id => statement_document.id),
              :id => 'edit_button', :class => 'ajax header_button text_button edit_text_button')
    else
      ''
    end
  end

  #
  # Creates a link to show the authors of the current node.
  #
  def authors_statement_node_link(statement_node,type = dom_class(statement_node))
    link_to(I18n.t('application.general.authors'), authors_statement_node_url(statement_node),
            :id => 'authors_button',
            :class => 'expandable header_button text_button authors_text_button',
            'data-content' => "#authors")
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

  # Returns the block heading for entering a new child for the given statement node
  def children_new_box_title(statement_node)
    I18n.t("discuss.statements.new.#{dom_class(statement_node)}")
  end

  # Returns the block heading for the children of the current statement node
  def children_box_title(type)
    I18n.t("discuss.statements.headings.#{type}")
  end

  # Returns the block heading for the siblings of the current statement node
  def sibling_box_title(type)
    content_tag :span, I18n.t("discuss.statements.headings.#{type}"), :class => 'label'
  end


  # Creates the cancel button in the new statement form (right link will be handled in jquery)
  def cancel_new_statement_node(cancel_js=false)
    link_to I18n.t('application.general.cancel'),
            :back,
            :class => 'cancel text_button cancel_text_button'
  end

  # Creates the cancel button in the edit statement form
  def cancel_edit_statement_node(statement_node, locked_at,type = dom_class(statement_node))
    link_to I18n.t('application.general.cancel'),
            cancel_statement_node_url(statement_node, :locked_at => locked_at.to_s),
           :class => "text_button cancel_text_button ajax"
  end


  ##############
  # Sugar & UI #
  ##############

  # Loads the right add statement image
  def statement_form_illustration(statement_node)
    image_tag("page/discuss/add_#{dom_class(statement_node)}_big.png",
              :class => 'statement_form_illustration')
  end

  # returns the right icon for a statement_node, determined from statement_node class and given size
  def statement_node_icon(statement_node, size = :medium)
    # remove me to have different sizes again
    image_tag("page/discuss/#{dom_class(statement_node)}_#{size.to_s}.png")
  end

  # Returns the context menu link for this statement_node.
  def statement_node_context_link(statement_node, language_ids, action = 'read', last_statement_node = false)
    return if (statement_document = statement_node.document_in_preferred_language(language_ids)).nil?
    link_to(h(statement_document.title),
             statement_node_url(statement_node),
             :class => "ajax no_border statement_link #{dom_class(statement_node)}_link ttLink",
             :title => I18n.t("discuss.tooltips.#{action}_#{dom_class(statement_node)}"))
  end

  #render the hint on the new statement forms for users with no spoken language defined
  def define_languages_hint
    content = ''
    content << content_tag(:li, :class => 'hint ttLink', :title => I18n.t('discuss.statements.statement_language_hint_tooltip')) do
      content_tag :p, I18n.t('discuss.statements.statement_language_hint', :url => my_profile_url)
    end
    content << tag('br')
    content
  end

  #render the hint on the edit statement forms to warn about the time the users have to edit it
  def edit_period_hint
    content = ''
    content << content_tag(:li, :class => 'hint ttLink') do
      content_tag :p, I18n.t('discuss.statements.edit_period_hint', :minutes => 60)
    end
    content
  end


  ##############
  # Navigation #
  ##############

  # Renders prev/next/siblings buttons for the current statement_node.
  def navigation_buttons(statement_node, type, opts={})
    buttons = ''
    if statement_node and statement_node.new_record?
      %w(prev next).each{|button| buttons << statement_tag(button.to_sym, type, true)}
      buttons << content_tag(:span, '&nbsp;', :class => 'show_siblings_button disabled')
    else
      buttons << content_tag(:span, '', :class => 'loading', :style => 'display:none')
      %w(prev next).each do |button|
        buttons << statement_button(statement_node,
                                    statement_tag(button.to_sym, type),
                                    type,
                                    :rel => button,
                                    :class => " statement_link #{opts[:classes]} #{button}")
      end

      buttons << descendants_button(statement_node, type, opts)
    end

    buttons
  end

  def descendants_button(statement_node, type, opts={})
    origin = opts[:origin]
    url = if statement_node.nil? or statement_node.class.name.underscore != type # ADD TEASERS
      if statement_node.nil?
        question_descendants_url(:origin => origin)
      else
        descendants_statement_node_url(statement_node, type)
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
    content_tag(:span, '&nbsp;', :class => 'show_siblings_button expandable',
                                 'data-content' => '.expandable_content',
                                 :href => url)
  end

  # Renders the correct prev/next image buttons
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

  # Inserts a button that links to the previous statement_node
  def statement_button(statement_node, title, type, options={})
    options[:class] ||= ''
    teaser = options[:class].include? 'add'
    options['data-id'] =
      teaser ? "#{statement_node.nil? ? '' : "#{statement_node.id}_"}add_#{type}" : statement_node.id
    url = statement_node.nil? ? '' : statement_node_url(statement_node)
    return link_to(title, url, options)
  end

  # Loads the link to a given statement, placed in the child panel section
  def link_to_child(title, statement_node,extra_classes, type = dom_class(statement_node))
    link_to h(title),
            statement_node_url(statement_node.target_id, :new_level => true),
            :class => "statement_link #{dom_class(statement_node)}_link #{extra_classes}"
  end

  # draws the statement image container
  def statement_image(statement_node, current_user)
    val = ""
    if statement_node.image.exists? or statement_node.has_author? current_user
      val << image_tag(statement_node.image.url(:medium), :id => 'statement_image', :class => 'image')
    end
    if statement_node.has_author? current_user and (!statement_node.published? or !statement_node.image.exists?)
      val << link_to(I18n.t('users.profile.picture.upload_button'),
                edit_statement_image_url(statement_node.statement_image, statement_node),
                :class => 'ajax upload_link button_150', :id => 'upload_image_link')
    end
    content_tag :div, val, :class => 'image_container', :id => 'image_container' if !val.blank?
  end

  # Renders the "more" link when the statement is loaded
  def more_children(statement_node,type)
    link_to I18n.t("application.general.more"),
            more_statement_node_url(statement_node, :page => 1, :type => type),
            :class => 'more_children ajax'
  end

  ###############
  # BREADCRUMBS #
  ###############


  # renders the breadcrumb given
  def render_breadcrumb(breadcrumbs)
    breadcrumb_trail = ""
    breadcrumbs.each_with_index do |b, index| #[id, classes, url, title]
      breadcrumb = content_tag :div, :class => 'breadcrumb' do
        content = ""
        content << content_tag(:span, I18n.t("discuss.statements.breadcrumbs.labels.#{b[0][0,2]}"), :class => 'label')
        content << content_tag(:span, I18n.t("discuss.statements.breadcrumbs.labels.over.#{b[0][0,2]}"), :class => 'over', :style => 'display:none')
        content << content_tag(:span, '>', :class => 'delimiter') if index != 0
        content << link_to(h(b[3].gsub(/\\;/, ',')), b[2], :id => b[0], :class => b[1])
        content
      end
      breadcrumb_trail << breadcrumb
    end
    breadcrumb_trail
  end

  # This class does the heavy lifting of actually building the pagination
  # links. It is used by the <tt>will_paginate</tt> helper internally.
  class MoreRenderer < WillPaginate::LinkRenderer


    def to_html
      html = page_link_or_span(@collection.next_page, 'disabled more_children', @options[:next_label])
      html = html.html_safe if html.respond_to? :html_safe
      @options[:container] ? @template.content_tag(:div, html, html_attributes) : html
    end

  end
end

