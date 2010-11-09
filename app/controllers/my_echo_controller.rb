class MyEchoController < ApplicationController

  helper :profile

  access_control do
    allow logged_in
  end

  def roadmap
    respond_to do |format|
      format.html
    end
  end

  def profile
    @profile = @current_user.profile
    @user    = @current_user
    @locale_language_id = locale_language_id
    render
  end

  def welcome
    render
  end

  def settings
    @profile = @current_user.profile
    @user    = @current_user
    render
  end
  
  {'notification' => ['newsletter','activity','drafting'], 'permission' => ['authorship']}.each do |type, contents|
    contents.each do |content|
      class_eval %(
        def set_#{content}_#{type}
          @user = User.find(params[:id])
          notify = params.has_key?(:notify)
          @user.#{content}_#{type} = notify ? 1 : 0
          @user.save
          respond_to do |format|
            format.js do
              set_info("users.#{type.pluralize}.#{content}." + (notify ? 'turned_on' : 'turned_off'))
              show_info_messages do
                replace_content('#{content}_#{type}_element',
                                :partial => 'users/components/check',
                                :locals => {:type => '#{type}', :content => '#{content}'})
              end
            end
          end
        end
      )
    end
  end
  
  
#  #Notifications
#  %w(newsletter activity drafting).each do |notification_type|
#    class_eval %(
#      def set_#{notification_type}_notification
#        @user = User.find(params[:id])
#        notify = params.has_key?(:notify)
#        @user.#{notification_type}_notification = notify ? 1 : 0
#        @user.save
#        respond_to do |format|
#          format.js do
#            set_info("users.notifications.#{notification_type}." + (notify ? 'turned_on' : 'turned_off'))
#            show_info_messages do
#              replace_content('#{notification_type}_notification_element',
#                              :partial => 'users/components/check',
#                              :locals => {:type => 'notification', :content => '#{notification_type}'})
#            end
#          end
#        end
#      end
#    )
#  end
#  
#  #Permissions
#  %w(authorship).each do |permission_type|
#    class_eval %(
#      def set_#{permission_type}_permission
#        @user = User.find(params[:id])
#        notify = params.has_key?(:notify)
#        @user.#{permission_type}_permission = notify ? 1 : 0
#        @user.save
#        respond_to do |format|
#          format.js do
#            set_info("users.permissions.#{permission_type}." + (notify ? 'turned_on' : 'turned_off'))
#            show_info_messages do
#              replace_content('#{permission_type}_permission_element',
#                              :partial => 'users/components/check',
#                              :locals => {:type => 'permission', :content => '#{permission_type}'})
#            end
#          end
#        end
#      end
#    )
#  end
end
