class TaoTagsController < ApplicationController

  before_filter :require_user

  helper :profile

  access_control do
    allow logged_in
  end

  # Generate auto completion based on tag values in the database. Load only 5
  # suggestions a time.
  auto_complete_for :tag, :value, :limit => 5

  # Create a new concernment connection for a user and a given topic with the
  # sort of concernment specified.
  #
  # Method:   POST
  # Params:   tag_value: string, user_id: integer, sort: integer
  # Response: JS
  #
  def create
    previous_completeness = current_user.profile.percent_completed
    tags = params[:tag][:value].split(',').map!{|t| t.strip}.select{|t| t.length > 0}
    context = EnumKey.find(params[:context_id])
    new_tags = tags - current_user.tao_tags.in_context(context).map{|tao_tag|tao_tag.tag.value}
    current_user.add_tags(new_tags, {:language_id => locale_language_id, :context_id => params[:context_id]})
    current_user.profile.calculate_completeness

    respond_to do |format|
      format.js do
        if current_user.profile.save
          current_completeness = current_user.profile.percent_completed
          if previous_completeness != current_completeness
            set_info("discuss.messages.new_percentage", :percentage => current_completeness)
          end
          tags_to_show = current_user.tao_tags.in_context(context).select do |tao_tag|
            new_tags.include? tao_tag.tag.value
          end
          render_with_info do |p|
            p.insert_html :bottom, "tao_tags_#{context.code}",
                          :partial => "tao_tags/tao_tag",
                          :collection => tags_to_show
            p.visual_effect :appear, dom_id(tags_to_show.last) unless tags_to_show.empty?
            p << "$('#new_tag_#{context.code}').reset();"
            p << "$('#tag_#{context.code}_id').focus();"
          end
        else
          show_error_messages(current_user)
        end
      end
    end
  end

  # Remove a specified concernment.
  #
  # Method:   DELETE
  # Params:   id:integer
  # Response: JS
  #
  def destroy
    @tao_tag = TaoTag.find(params[:id])
    profile = current_user.profile
    previous_completeness = profile.percent_completed
    @tao_tag.destroy
    profile.calculate_completeness
    profile.save
    current_completeness = profile.percent_completed
    if previous_completeness != current_completeness
      set_info("discuss.messages.new_percentage", :percentage => current_completeness)
    end

    respond_to do |format|
      format.js do
        render_with_info do |p|
          p.remove dom_id(@tao_tag)
        end
      end
    end
  end

end
