class AboutItemsController < AdminController
  layout 'admin'

  before_filter :action_links_order


  # Admin may perform everything.
  access_control do
    allow :admin
  end


  active_scaffold :about_items do |config|
    config.label = "About items"
    config.columns = [:about_category_id, :photo, :name, :responsibility, :description, :index]
    list.sorting = [{:about_category_id => 'DESC'}, {:index => 'ASC'}]
    config.columns[:about_category_id].form_ui = :select
    config.columns[:about_category_id].options[:options] = AboutCategory.all.map{|c|[c.value, c.id]}
    config.create.multipart = true
    config.update.multipart = true
    config.list.per_page = 10
    Language.all.each do |l|
      config.action_links.add :index, :label => l.value, :parameters => {:locale => l.code}, :page => true
    end
  end


  def before_create_save(record)
    record.photo = params[:record_photo]
  end

  def before_update_save(record)
    record.photo = params[:record_photo]
  end

  protected

  # only authenticated admin users are authorized to create projects
  def create_authorized?
    user = current_user
    !user.nil? && user.has_role?(:admin)
  end


  # Moving action_name link to last
  def action_links_order
    links = active_scaffold_config.action_links
    link = links[:action_name]
    if link
      links.delete :action_name
      links << link
    end
  end





end
