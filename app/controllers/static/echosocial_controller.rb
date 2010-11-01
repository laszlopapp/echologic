class Static::EchosocialController < ApplicationController
  helper :static_content

  skip_before_filter :require_user

  %w(show features extensions).each do |name|
    class_eval %(
      def #{name}
        render_static_show :partial => '#{name}', :layout => 'echosocial'
      end
    )
  end

  #
  # Sets and persists the given state and the state_since timestamp.
  #
  %w(about imprint data_privacy).each do |name|
    class_eval %(
      def #{name}
        render_static_outer_menu :partial => '#{name}', :layout => 'echosocial', :locals => {:title => I18n.t('static.echosocial.#{name}.title')}
      end
    )
  end
end
