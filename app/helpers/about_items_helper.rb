module AboutItemsHelper
  def photo_column(record)
    image_tag(record.photo.url(:small))
  end
  
  def photo_form_column(record, options)
    file_field_tag "record_photo",:accept => 'image/jpeg,image/png,image/pjpeg,image/x-png',
                   :value => record.photo
  end
 
  def collaboration_team_id_column(record)
    record.collaboration_team.value
  end  
end
