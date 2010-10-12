class AboutItemsController < AdminController
  layout 'admin'
  
  
  
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
    config.list.per_page = 10
    Language.all.each do |l|
      config.action_links.add :index, :label => l.value, :parameters => {:locale => l.code}, :page => true
    end
  end
  
  protected

  # only authenticated admin users are authorized to create projects
  def create_authorized?
    user = current_user
    !user.nil? && user.has_role?(:admin)
  end


  
  def before_create_save(record)
    record.photo = params[:record_photo]
  end

  def before_update_save(record) 
    record.photo = params[:record_photo]
  end

end
