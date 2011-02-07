module NewslettersHelper
  def text_form_column(record, input_name)
    fckeditor_textarea(:record, :text, :toolbarSet => "Easy", :name => input_name, :width => "740px", :height => "500px")
  end

  def text_column(record)
    sanitize(record.text)
  end
  
  def created_at_column(record)
    record.created_at.to_date
  end
end