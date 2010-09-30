class AdminItemsController < ApplicationController
  
  # All reporting actions require a logged in user
  before_filter :require_user
  
  
  # Admin may perform everything.
  access_control do
    allow :admin
  end
  
  # Show all items.
  def index
    @about_items = AboutItem.by_index
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
end