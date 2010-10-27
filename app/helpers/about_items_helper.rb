module AboutItemsHelper
  def photo_column(record)
    image_tag(record.photo.url(:small))
  end

  def photo_form_column(record, options)
    file_field_tag "record_photo",:accept => 'image/jpeg,image/png,image/pjpeg,image/x-png',
                   :value => record.photo
  end

#  def description_column(record)
#    record.description(params[:code])
#  end

  def about_category_id_column(record)
    link_to record.about_category.value, url_for(:action => :index, :about_category_id => record.about_category_id)
  end
end
