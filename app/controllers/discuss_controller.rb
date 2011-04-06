class DiscussController < ApplicationController

  skip_before_filter :require_user, :only => [:roadmap, :index]

  auto_complete_for :tag, :value, :limit => 20 do |tags|
    @@tag_filter.call %w(*), tags, 7
  end

  # GET /discuss
  def roadmap
    respond_to do |format|
      format.html
    end
  end

  def index
    respond_to do |format|
      format.html
    end
  end
end
