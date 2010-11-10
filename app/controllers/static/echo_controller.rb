class Static::EchoController < ApplicationController
  helper :static_content

  skip_before_filter :require_user

  # echo - The Project
  def show
    render_static_show :partial => 'show'
  end

  # echo - The Project
  def echo
    render_static_show :partial => 'echo', :locals => {:menu_item => 'echo'}
  end

  %w(discuss connect act echo_on_waves).each do |name|
    class_eval %(
      def #{name}
        render_static_show :partial => '#{name}', :locals => {:menu_item => 'echo', :submenu_item => '#{name}'}
      end
    )
  end
end
