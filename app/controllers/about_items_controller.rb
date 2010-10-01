class AboutItemsController < ApplicationController
  # All reporting actions require a logged in user
  before_filter :require_user
  
  
  # Admin may perform everything.
  access_control do
    allow :admin
  end
  
  
  active_scaffold :about_items do |config|
    config.label = "Members"
    config.columns = [:photo, :name, :description, :collaboration_team_id, :index]
    config.update.multipart = true
#    list.columns.exclude :comments
    list.sorting = {:name => 'ASC'}
#    columns[:phone].label = "Phone #"
    config.columns[:collaboration_team_id].form_ui = :select
    config.columns[:collaboration_team_id].options[:options] = CollaborationTeam.all.map{|c|[c.value, c.id]}
  end

end
