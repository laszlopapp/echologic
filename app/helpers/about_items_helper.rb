module AboutItemsHelper
  def photo_column(record)
    image_tag(record.photo.url(:small))
  end
  
  def collaboration_team_id_column(record)
    record.collaboration_team.value
  end
  
#  def collaboration_team_form_column(column)
#    puts column.inspect
#    select('about_item', column.name, CollaborationTeam.all.map{|c|[c.value, c.code]}, {})
#  end
end
