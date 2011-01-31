module PublishableModuleHelper
  #
  # get the text that shows up on the top left corner of discuss search results
  #
  def questions_count_text(count, search_terms = nil)
    text = count_text("discuss", count)
    text << " #{I18n.t('discuss.for', :value => search_terms)}" if !search_terms.blank?
    text
  end


  #
  # create question button above the discuss search results and on the left corner of my questions
  #
  def create_question_link_for(search_terms=nil)
    search_terms = search_terms.nil? ? '' : search_terms.gsub(/,/,'\\;')
    origin = search_terms.blank? ? "ds" : "sr#{search_terms}"
    link_to(new_question_url(:origin => origin, :bids => origin),
            :id => 'create_question_link') do
      content_tag(:span, '',
                  :class => "new_question create_statement_button_mid create_question_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_question"))
    end
  end


  #
  # question link for the discuss search results
  #
  def link_to_question(title, question,long_title,search_terms=nil)
    search_terms = search_terms.nil? ? '' : search_terms.gsub(/,/,'\\;')
    origin = search_terms.blank? ? "ds" : "sr#{search_terms}"
    link_to statement_node_url(question, :origin => origin, :bids => origin),
               :title => "#{h(title) if long_title}",
               :class => "avatar_holder#{' ttLink no_border' if long_title }" do
      image_tag question.image.url(:small)
    end
  end


  #
  # Creates a button link to create a new question (SIDEBAR).
  #
  def add_new_question_button(origin = nil)
    link_to(I18n.t("discuss.statements.types.question"),
            new_question_url(:origin => origin, :bids => origin),
            :class => "question_link resource_link ajax")
  end


  #
  # publish button that appears on the right top corner of the statement
  #
  def publish_statement_node_link(statement_node, statement_document)
    if current_user and
       statement_document.author == current_user and !statement_node.published?
      link_to(I18n.t('discuss.statements.publish'),
              { :controller => :statements, :id => statement_node.id, :action => :publish, :in => :summary },
              :class => 'ajax_put header_button text_button publish_text_button ttLink',
              :title => I18n.t('discuss.tooltips.publish'))
    else
      ''
    end
  end

  #
  # linked title of question on my question area
  #
  def my_issue_title(title,question)
    link_to(h(title),statement_node_url(question, :origin => :mi, :bids => :mi), :class => "statement_link ttLink no_border",
            :title => I18n.t("discuss.tooltips.read_#{question.class.name.underscore}"))
  end

  #
  # linked image of question on my question area
  #
  def my_issue_image(question)
    link_to statement_node_url(question, :origin => :mi, :bids => :mi), :class => "avatar_holder" do
      image_tag question.image.url(:small)
    end
  end

  #
  # create question button above the discuss search results and on the left corner of my questions
  #
  def create_my_issue_link_for
    link_to(new_question_url(:origin => :mi, :bids => :mi),
            :id => 'create_question_link') do
      content_tag(:span, '',
                  :class => "new_question create_statement_button_mid create_question_button_mid ttLink no_border",
                  :title => I18n.t("discuss.tooltips.create_question"))
    end
  end

  # Creates a 'Publish' button to release the question on my questions area.
  def publish_button_or_state(statement_node)
    if !statement_node.published?
      link_to(I18n.t("discuss.statements.publish"),
              publish_statement_node_path(statement_node),
              :class => 'ajax_put publish_button ttLink',
              :title => I18n.t('discuss.tooltips.publish'))
    else
      content_tag :span , I18n.t('discuss.statements.states.published'), :class => 'publish_button'
    end
  end

  # returns a collection from possible statement states to be used on radios and select boxes
  def statement_states_collection
    StatementState.all.map{|s|[I18n.t("discuss.statements.states.initial_state.#{s.code}"),s.id]}
  end
end