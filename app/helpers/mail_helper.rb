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

end
