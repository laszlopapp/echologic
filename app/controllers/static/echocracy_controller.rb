class Static::EchocracyController < ApplicationController

  # echocracy - The Benefits / The Actors
  def show
    render_static :partial => 'show'
  end

  # echocracy - Citizens
  def citizens
    render_static :partial => 'citizens'
  end

  # echocracy - Scientists
  def scientists
    render_static :partial => 'scientists'
  end

  # echocracy - Decision makers
  def decision_makers
    render_static :partial => 'decision_makers'
  end

  # echocracy - Organisations
  def organisations
    render_static :partial => 'organisations'
  end
  
  private
  def render_static(opts={:partial => 'show'})
    respond_to do |format|
      format.html { render :partial => opts[:partial], :layout => 'static'}
      format.js { render :template => 'layouts/tabContainer'}
    end
  end
end
