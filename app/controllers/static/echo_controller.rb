class Static::EchoController < ApplicationController

  # echo - The Project
  def show
    render_static_show :partial => 'show'
  end

  # echo - The Project
  def echo
    render_static_show :partial => 'echo', :locals => {:menu_item => 'echo'}
  end

  # echo - Discuss
  def discuss
    render_static_show :partial => 'discuss', :locals => {:menu_item => 'echo', :submenu_item => 'discuss'}
  end

  # echo - Connect
  def connect
    render_static_show :partial => 'connect', :locals => {:menu_item => 'echo', :submenu_item => 'connect'}
  end

  # echo - Act
  def act
    render_static_show :partial => 'act', :locals => {:menu_item => 'echo', :submenu_item => 'act'}
  end

  # echo - echo on waves
  def echo_on_waves
    render_static_show :partial => 'echo_on_waves', :locals => {:menu_item => 'echo', :submenu_item => 'echo_on_waves'}
  end
end
