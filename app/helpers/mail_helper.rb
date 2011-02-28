module MailHelper

  # Returns the full URL to the given path.
  def full_url(path)
    'http://' + ECHO_HOST + path
  end

  #
  # Aux Function on activity tracking mailing
  # Args: documents:  hash of language_id => titles ; language_ids: array of ordered language ids
  # Returns an array containing the first document id and title found according to the language ids ordering
  #
  def get_document_in_preferred_language(documents, language_ids)
    document = nil
    language_ids.each do |l_id|
      l_id = l_id.to_s
      if documents.has_key?(l_id)
         document = [l_id, documents[l_id]]
         break
      end
    end
    document = documents.to_a.first if document.nil?
    document
  end

  def inline_statement_link(document, event)
    icon_url = full_url("/images/page/discuss/#{event['type']}_16.png")
    content_tag(:li, link_to(document[1], statement_node_url(event['id'], :locale => Language[document[0].to_i].code)),
                :class => "statement_link #{event['type']}",
                :style => "list-style: none; background: url(#{icon_url}) no-repeat 0 0; padding-left: 20px; margin: 7px 0;")
  end

end
