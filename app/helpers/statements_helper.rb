module StatementsHelper
  ########
  # URLs #
  ########
  
  def new_child_url(type, opts={})
    send("new_#{type.downcase}_url",opts)
  end

  def echo_url(statement_node, type, opts={})
    send("echo_#{type.downcase}_url",opts)
  end
  
  def unecho_url(statement_node, type, opts={})
    send("unecho_#{type.downcase}_url",opts)
  end

  def edit_url(statement_node, opts={})
    send("edit_#{dom_class(statement_node).downcase}_url",statement_node,opts)
  end

  def new_translation_url (statement_node, type, opts={})
    send("new_translation_#{type.downcase}_url",statement_node,opts)
  end

  def create_translation_url (statement_node, type)
    send("create_translation_#{type.downcase}_url",statement_node)
  end
  
  def cancel_url (statement_node, type, opts={})
    send("cancel_#{type.downcase}_url",statement_node, opts)
  end

  def upload_image_url (statement_node, type, opts={})
    send("upload_image_#{type.downcase}_url",statement_node, opts)
  end

  def reload_image_url (statement_node, type, opts={})
    send("reload_image_#{type.downcase}_url",statement_node, opts)
  end

  def children_url (statement_node, type, opts={})
    send("children_#{type.downcase}_url",statement_node, opts)
  end


  #########
  # Links #
  #########

  def search_category(category)
    content_tag :span, 
                I18n.t('discuss.search.in', :category => I18n.t("discuss.topics.#{category}.short_name")), 
                :class => "search_category" if category
  end

  #
  # Creates a link to create a new statement for the given statement
  # (appears INSIDE of the children statements panel).
  #
  def create_new_statement_link(statement_node, type)
    content_tag :li do
      link_to(I18n.t("discuss.statements.create_#{type}_link"),
              new_child_url(type, :parent_id => statement_node.id),
              :id => "create_#{type}_link",
              :class => "ajax add_new_button text_button create_#{type}_button ttLink no_border",
              :title => I18n.t("discuss.tooltips.create_#{type}"))
    end
  end

  #
  # Creates a link to create a new sibling statement for the given statement (appears in the SIDEBAR).
  #
  def create_new_sibling_statement_button(statement_node)
    type = dom_class(statement_node)
    link_to(new_child_url(type, :parent_id => statement_node.parent ? statement_node.parent.id : nil),
            :id => "create_#{type}_link",
            :class => "#{statement_node.echoable? ? 'ajax' : ''}") do
      content_tag(:span, '',
                  :class => "create_statement_button_mid create_#{type}_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_#{type}"))

    end
  end

  def create_translate_statement_link(statement_node, statement_document, css_class = "")
     type = dom_class(statement_node)
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
      link_to(I18n.t('application.general.edit'), edit_url(statement_node,:current_document_id => statement_document.id),
              :class => 'ajax header_button text_button edit_text_button')
    else
      ''
    end
  end
  
  def delete_statement_node_link(statement_node)
    link_to I18n.t('discuss.statements.delete_link'),
            url_for(statement_node),
            :class => 'admin_action',
            :method => :delete,
            :confirm => I18n.t('discuss.statements.delete_confirmation')
  end
  
  def function_buttons(statement_node, statement_document)
    edit_statement_node_link(statement_node, statement_document)
  end

  # Returns the block heading for entering a new child for the given statement_node
  def children_new_box_title(statement_node)
    I18n.t("discuss.statements.new.#{dom_class(statement_node)}")
  end

  def cancel_new_statement_node(statement_node,cancel_js=false)
    link_to I18n.t('application.general.cancel'),
            session[:last_statement_node] ?
              send("#{dom_class(statement_node)}_url",session[:last_statement_node]) : (statement_node.parent or discuss_url),
            :class => 'ajax text_button cancel_text_button'
  end

  def cancel_edit_statement_node(statement_node, locked_at)
    type = dom_class(statement_node)
    link_to I18n.t('application.general.cancel'),
            cancel_url(statement_node, type, :locked_at => locked_at.to_s),
           :class => "text_button cancel_text_button ajax"
  end


  ##############
  # Sugar & UI #
  ##############

  def statement_form_illustration(statement_node)
    image_tag("page/discuss/add_#{dom_class(statement_node)}_big.png",
              :class => 'statement_form_illustration')
  end

  # returns the right icon for a statement_node, determined from statement_node class and given size
  def statement_node_icon(statement_node, size = :medium)
    # remove me to have different sizes again
    image_tag("page/discuss/#{dom_class(statement_node)}_#{size.to_s}.png")
  end

  # inserts a status bar based on the support ratio  value
  # (support ratio is the calculated ratio for a statement_node,
  # representing and visualizing the agreement a statement_node has found within the community)
  def supporter_ratio_bar(statement_node, show_label = false)
    if statement_node.supporter_count < 2
      label = I18n.t('discuss.statements.echo_indicator.one',
                     :supporter_count => statement_node.supporter_count)
    else
      label = I18n.t('discuss.statements.echo_indicator.many',
                     :supporter_count => statement_node.supporter_count)
    end

    html = ''.html_safe!
    if show_label
      if statement_node.ratio > 1
        html += content_tag :span, '', :class => "echo_indicator", :alt => statement_node.ratio
      else
        html += content_tag :span, '', :class => "no_echo_indicator"
      end
      html += content_tag :span, label, :class => "supporters_label"
    else
      if statement_node.ratio > 1
        html += content_tag :span, '', :class => "echo_indicator ttLink", :title => label, :alt => statement_node.ratio
      else
        html += content_tag :span, '', :class => "no_echo_indicator ttLink", :title => label
      end
    end

    html
  end

  # Renders the button for echo and unecho.
  def render_echo_button(statement_node, echo = true)
    type = dom_class(statement_node)
    return if !statement_node.echoable?
    title = I18n.t("discuss.tooltips.#{echo ? '' : 'un'}echo")
    link_to(url_for(echo ? echo_url(statement_node,type) : unecho_url(statement_node,type)),
                    :class => "ajax_put",
                    :id => 'echo_button') do
       content_tag :span, '', :class => "#{echo ? 'not_' : '' }supported ttLink no_border", :title => "#{title}"
    end
    tag("br")
  end

  # Returns the context menu link for this statement_node.
  def statement_node_context_link(statement_node, language_ids, action = 'read', last_statement_node = false)
    return if (statement_document = statement_node.document_in_preferred_language(language_ids)).nil?
    link = link_to(h(statement_document.title),
                   url_for(statement_node),
                   :class => "ajax no_border statement_link #{dom_class(statement_node)}_link ttLink",
                   :title => I18n.t("discuss.tooltips.#{action}_#{dom_class(statement_node)}"))
    if statement_node.echoable?
      link << supporter_ratio_bar(statement_node, last_statement_node)
    end
    return link
  end


  ##############
  # Navigation #
  ##############

  # Insert prev/next buttons for the current statement_node.
  def prev_next_buttons(statement_node)
    type = dom_class(statement_node)
    key = ("current_" + type).to_sym
    if session[key].present? and session[key].include?(statement_node.id)
      index = session[key].index(statement_node.id)
      buttons = if session[key].length == 1
                  statement_tag(:prev, type, true)
                else
                  s = index == 0 ? session[key][session[key].length-1] : session[key][index-1]
                  statement_button(s, statement_tag(:prev, type), :rel => 'prev')
                end
      buttons << if session[key].length == 1
                   statement_tag(:next, type, true)
                 else
                   s = index == session[key].length-1 ? session[key][0] : session[key][index+1]
                   statement_button(s, statement_tag(:next, type), :rel => 'next')
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
    options[:class] += !stmt.taggable? ? ' ajax' : ''
    return link_to(title, url_for(stmt), options)
  end

  def link_to_child(title,statement_node,extra_classes)
    link_to h(title),
            url_for(statement_node),
            :class => "ajax statement_link #{dom_class(statement_node)}_link #{extra_classes}"
  end

  def translation_upper_box(language_from, language_to)
    val = "#{image_tag 'page/translation/babelfish_left.png', :class => 'fish_left'}"
    val << (content_tag :span, language_from, :class => 'language_label from_language')
    val << "#{image_tag 'page/translation/translation_arrow.png',:class => 'arrow'}"
    val << "#{image_tag 'page/translation/babelfish_right.png', :class => 'fish_right'}"
    val << (content_tag :span, language_to, :class => "language_label to_language")
    val
  end

  # draws the statement image container
  def statement_image(statement_node, current_user)
    val = ""
    if statement_node.image.exists? or statement_node.has_author? current_user
      val << image_tag(statement_node.image.url(:medium), :id => 'statement_image', :class => 'image')
    end
    if statement_node.has_author? current_user and (!statement_node.published? or !statement_node.image.exists?)
      val << link_to(I18n.t('users.profile.picture.upload_button'),
                upload_image_url(statement_node, dom_class(statement_node)),
                :class => 'ajax upload_link button_150', :id => 'upload_image_link')
    end
    content_tag :div, val, :class => 'image_container', :id => 'image_container' if !val.blank?
  end

  #draws the "more" link when the statement is loaded
  def more_children(statement_node)
    link_to I18n.t("application.general.more"),
            children_url(statement_node, dom_class(statement_node).downcase, :page => 1),
            :class => 'more_children ajax'
  end

  # returns a collection from possible statement states to be used on radios and select boxes
  def statement_states_collection
    StatementState.all.map{|s|[I18n.t("discuss.statements.states.initial_state.#{s.code}"),s.id]}
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

