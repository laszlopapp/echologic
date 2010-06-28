class TaoTagsController < ApplicationController

  before_filter :require_user

  helper :profile

  access_control do
    allow logged_in
  end

  # Generate auto completion based on tag values in the database. Load only 5
  # suggestions a time.
  auto_complete_for :tag, :value, :limit => 5

  # Creates a new group of tags for a specific user given a specific context
  #
  # Method:   POST
  # Params:   tag_value: string, context_id: integer
  # Response: JS
  #
  def create
    previous_completeness = current_user.profile.percent_completed
    tags = params[:tag][:value].split(',')
    new_tags = tags - current_user.tao_tags.map{|tao_tag|tao_tag.tag.value}
    current_user.add_tags(tags,{:language_id => locale_language_id, :context_id => params[:context_id]})
    context_code = EnumKey.find(params[:context_id]).code
    current_user.profile.calculate_completeness #maybe there's a better solution for this...
    respond_to do |format|
      format.js do
        if current_user.save
          current_completeness = current_user.profile.percent_completed
          set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness

          tags_to_show = current_user.tao_tags.select{|tao_tag| new_tags.include? tao_tag.tag.value}
          render_with_info do |p|
            p.insert_html :bottom, "tao_tags_#{context_code}", :partial => "tao_tags/tao_tag", :collection => tags_to_show
            p.visual_effect :appear, dom_id(tags_to_show.last) unless tags_to_show.empty?
            p << "$('#new_tag_#{context_code}').reset();"
            p << "$('#tag_#{context_code}_id').focus();"
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
    previous_completeness = current_user.profile.percent_completed
    @tao_tag.destroy
    @tao_tag.tao.profile.calculate_completeness #maybe there's a better solution for this...
    current_completeness = @tao_tag.tao.profile.nil? ? previous_completeness : @tao_tag.tao.profile.percent_completed
    set_info("discuss.messages.new_percentage", :percentage => current_completeness) if previous_completeness != current_completeness

    respond_to do |format|
      format.js do
        ender_with_info do |p|
          p.remove dom_id(@tao_tag)
        end
      end
    end
  end
end
