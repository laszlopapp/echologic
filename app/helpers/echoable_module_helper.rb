module EchoableModuleHelper

  # Inserts a status bar based on the support ratio value.
  # (The support ratio is the calculated ratio for a statement_node,
  # representing and visualizing the agreement a statement_node has found within the community.)
  def supporter_ratio_bar(statement_node,
                          show_label = false,
                          previous_statement = statement_node.parent,
                          type = statement_node.class.name)
    # TODO:How to spare calculating this label two times (see next method, they're almost always sequencially triggered)
    if show_label
      label = supporters_number(statement_node)
    end

    extra_classes = show_label ? 'supporters_bar ttLink' : 'supporters_bar'
    if !statement_node.nil? and (statement_node.new_record? or statement_node.ratio(previous_statement,type) > 1)
      content_tag(:span, '', :class => "echo_indicator #{extra_classes}", :title => label,
                  :alt => statement_node.new_record? ? 10 : statement_node.ratio(previous_statement,type))
    else
      content_tag(:span, '', :class => "no_echo_indicator #{extra_classes}",:title => label)
    end
  end


  # Inserts a supporters label with the supporters number of this statement
  def supporters_label(statement_node, show_label = false)
    label = supporters_number(statement_node)
    content_tag(:span, label, :class => "supporters_label", :style => "#{show_label ? '' : 'display:none' }")
  end


  # Returns the right line that shows up below the ratio bar (1 supporter, 2 supporters...)
  def supporters_number(statement_node)
    I18n.t("discuss.statements.echo_indicator.#{ statement_node.supporter_count <= 1 ? 'one' : 'many'}",
           :supporter_count => statement_node.new_record? ? 1 : statement_node.supporter_count)
  end

  def new_form_echo_button(statement_node)
    echo_button :div, 'new_record', nil, false, dom_class(statement_node) do |button|
      button << hidden_field_tag('echo', true)
    end

#    content_tag(:div, :class => 'echo_button') do
#      content = ''
#      content << echo_button_icon(false, 'new_record')
#      content << hidden_field_tag('echo', true)
#      content << echo_button_label(type)
#      content
#    end
  end

  def show_echo_button(statement_node)
    echo = !(current_user && statement_node.supported?(current_user))
    href = echo ? echo_statement_node_url(statement_node) : unecho_statement_node_url(statement_node)

    echo_button :a, '', {:href => "#{href}"}, echo, dom_class(statement_node)

#    link_to(href, :class => "echo_button") do
#      content = ''
#      content << echo_button_icon(echo)
#      content << echo_button_label(type)
#      content
#    end
  end

  def echo_button(botton_class, extra_classes, botton_attrs, echo, type)
    #title = I18n.t("discuss.tooltips.#{echo ? '' : 'un'}echo")
    options = {
      :class => "echo_button #{echo ? 'not_' : '' }supported #{extra_classes}"
    }
    options.merge!(botton_attrs) unless botton_attrs.blank?

    content_tag(botton_class, '', options) do
      button = ''
      button << content_tag(:span, '', :class => 'echo_button_icon')
      yield button if block_given?
      button << echo_button_label(type)
      button
    end
  end

  def echo_button_label(type)
    content_tag(:span, '',
                :class => 'label',
                'data-not-supported' => I18n.t("discuss.statements.echo_#{type}_link"),
                'data-supported' => I18n.t("discuss.statements.unecho_#{type}_link"))
  end

  # Renders the echo/unecho button element.
  def echo_button_icon(echo, extra_classes = '')
#    title = I18n.t("discuss.tooltips.#{echo ? '' : 'un'}echo")
#    content_tag :span, '',
#                :class => "#{echo ? 'not_' : '' }supported ttLink no_border #{extra_classes} echo_icon",
#                :title => "#{title}"
  end


end