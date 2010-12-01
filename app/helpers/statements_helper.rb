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
    statement_node.class.expected_children_types.each do |child_type|
      dom_child_class = child_type.to_s.underscore
      type_children = children[child_type] || more_statement_node_url(statement_node, :type => dom_child_class)
      val << render(:partial => child_type.to_s.constantize.children_template, :locals => {:type => dom_child_class, :children => type_children})
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
  def create_new_child_statement_link(statement_node, child_type)
    link_to(I18n.t("discuss.statements.create_#{child_type}_link"),
            new_statement_node_url(statement_node,child_type),
            :id => "create_#{child_type}_link",
            :class => "ajax add_new_button text_button create_#{child_type}_button ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_#{child_type}"))
  end

  #
  # Creates a link to create a new sibling statement for the given statement (appears in the SIDEBAR).
  #
  def create_new_sibling_statement_button(statement_node, type = dom_class(statement_node))
    link_to(new_statement_node_url(statement_node.parent, type),
            :id => "create_#{type}_link",
            :class => "#{statement_node.echoable? ? 'ajax' : ''}") do
      content_tag(:span, '',
                  :class => "create_statement_button_mid create_#{type}_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_#{type}"))

    end
  end
  
  #
  # Creates a link to create a new sibling statement for the given statement (appears in the SIDEBAR).
  #
  def add_sibling_statement_link(statement_node, type = dom_class(statement_node))
    link_to(I18n.t("discuss.statements.create_#{type}_link"),
            new_child_url(type, :parent_id => statement_node.parent ? statement_node.parent.id : nil),
            :id => "create_#{type}_link",
            :class => "#{statement_node.echoable? ? 'ajax' : ''} add_new_button text_button create_#{type}_button")
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
              :id => 'authors_button', :class => 'ajax_expandable header_button text_button authors_button', 'data-content' => "#authors")
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
    content_tag :span, val
  end

  # Returns the block heading for entering a new child for the given statement node
  def children_new_box_title(statement_node)
    I18n.t("discuss.statements.new.#{dom_class(statement_node)}")
  end
  
  # Returns the block heading for the children of the current statement node
  def children_box_title(type)
    I18n.t("discuss.statements.headings.#{type}")
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


  ##############
  # Navigation #
  ##############

  # Insert prev/next buttons for the current statement_node.
  def prev_next_buttons(statement_node, extra_classes = '', type = dom_class(statement_node))
    buttons = ''
    if statement_node and statement_node.new_record?
      %w(prev next).each{|b| buttons << statement_tag(b.to_sym, type, true)}
    else
      %w(prev next).each{|b| buttons << statement_button(statement_node, statement_tag(b.to_sym, type), type, :rel => b, :class => " statement_link #{extra_classes} #{b}")}
    end
    buttons
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

  # Insert a button that links to the previous statement_node
  def statement_button(current_node, title, type, options={})
    options[:class] ||= ''
    teaser = options[:class].include? 'add'
    options['data-id'] = teaser ? "#{current_node.nil? ? '' : "#{current_node.id}_"}add_#{type}" : current_node.id
    url = current_node.nil? ? '' : statement_node_url(current_node)
    return link_to(title, url, options)
  end

  
  # Loads the link to a given statement, placed in the child panel section
  def link_to_child(title, statement_node,extra_classes, type = dom_class(statement_node))
    link_to h(title),
            statement_node_url(statement_node, :new_level => true),
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
                upload_image_statement_node_url(statement_node),
                :class => 'ajax upload_link button_150', :id => 'upload_image_link')
    end
    content_tag :div, val, :class => 'image_container', :id => 'image_container' if !val.blank?
  end

  #draws the "more" link when the statement is loaded
  def more_children(statement_node,type)
    link_to I18n.t("application.general.more"),
            children_statement_node_url(statement_node, :page => 1, :type => type),
            :class => 'more_children ajax'
  end
  
  # renders the breadcrumb given
  def render_breadcrumb(breadcrumbs)
    content_tag :div, :id => 'breadcrumbs', :class => 'breadcrumbs' do 
      elements = []
      @breadcrumbs.each do |txt, path|
        elements << link_to(h(txt), path)
      end
      elements.join('_')
    end
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

