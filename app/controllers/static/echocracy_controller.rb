class Static::EchocracyController < ApplicationController

  # echocracy - The Benefits / The Actors
  def show
    render_static_show :partial => 'show'
  end

  # echocracy - Citizens
  def citizens
    render_static_show :partial => 'citizens'
  end

  # echocracy - Scientists
  def scientists
    render_static_show :partial => 'scientists'
  end

  # echocracy - Decision makers
  def decision_makers
    render_static_show :partial => 'decision_makers'
  end

  # echocracy - Organisations
  def organisations
    render_static_show :partial => 'organisations'
  end
end
