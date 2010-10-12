class AboutItemsController < ApplicationController
  # All reporting actions require a logged in user
  before_filter :require_user
  
  # Admin may perform everything.
  access_control do
    allow :admin
  end
  
  
  active_scaffold :about_items do |config|
    config.label = "Members"
    config.columns = [:collaboration_team_id, :photo, :name, :description, :index]
    list.sorting = [{:collaboration_team_id => 'DESC'}, {:index => 'ASC'}]
    config.columns[:collaboration_team_id].form_ui = :select
    config.columns[:collaboration_team_id].options[:options] = CollaborationTeam.all.map{|c|[c.value, c.id]}
    config.create.multipart = true
    config.update.multipart = true
  end

  def before_create_save(record)
    record.photo = params[:record_photo]
  end

  def before_update_save(record) 
    record.photo = params[:record_photo]
  end

end
