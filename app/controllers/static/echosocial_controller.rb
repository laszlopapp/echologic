class Static::EchosocialController < ApplicationController

  # Default page redirected to echoLogic - The Mission
  def show
    render_static :partial => 'show'
  end

  # echosocial - Features
  def features
    render_static :partial => 'features'
  end

  # echosocial - Benefits
  def extensions
    render_static :partial => 'extensions'
  end

  # About
  def about
    render_outer_menu :partial => 'about', :locals => {:title => I18n.t('static.echosocial.about.title')}
  end

  # Imprint
  def imprint
    render_outer_menu :partial => 'imprint', :locals => {:title => I18n.t('static.echosocial.imprint.title')}
  end

  # Data privacy
  def data_privacy
    render_outer_menu :partial => 'data_privacy', :locals => {:title => I18n.t('static.echosocial.data_privacy.title')}
  end
  
  private
  def render_static(opts={:partial => 'show',:locals => {}})
    respond_to do |format|
      format.html { render :partial => opts[:partial], :layout => 'echosocial'}
      format.js { render :template => 'layouts/tabContainer'}
    end
  end
  
  def render_outer_menu(opts={})
    respond_to do |format|
      format.html { render :partial => opts[:partial], :layout => 'echosocial', :locals => opts[:locals]}
      format.js { render :template => 'layouts/outerMenuDialog' , :locals => opts[:locals]}
    end
  end
end
