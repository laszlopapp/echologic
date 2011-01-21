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

  # Render the appropriate echo button onto the action bar
  def render_echo_button(statement_node)
    statement_node.new_record? ? new_form_echo_button(statement_node) : show_echo_button(statement_node)
  end


  # Renders echo button on new statement forms
  def new_form_echo_button(statement_node)
    echo_button :div, true, dom_class(statement_node), :class => 'new_record' do |button|
      button << hidden_field_tag('echo', true)
    end
  end

  # Renders echo button on statement views
  def show_echo_button(statement_node)
    echoed = current_user && statement_node.supported?(current_user)
    href = echoed ? unecho_statement_node_url(statement_node) : echo_statement_node_url(statement_node) 
    echo_button :a, echoed, dom_class(statement_node), :href => href
  end

  #
  # Renders echo button
  # button_tag : symbol : html tag that contains the elements
  # echoed: true/false : whether button state is echoed or not
  # type : string (statement_node class) : selects the right label 
  #
  def echo_button(button_tag, echoed, type, opts={})
    opts[:class] ||= ''
    opts[:class] << " echo_button #{echoed ? '' : 'not_' }supported"
    opts[:id] ||= "echo_button"
    
    content_tag(button_tag, opts) do
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
end