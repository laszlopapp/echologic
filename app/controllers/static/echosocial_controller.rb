class Static::EchosocialController < ApplicationController

  # Default page redirected to echoLogic - The Mission
  def show
    render_static :partial => 'show', :layout => 'echosocial'
  end

  # echosocial - Features
  def features
    render_static :partial => 'features', :layout => 'echosocial'
  end

  # echosocial - Benefits
  def extensions
    render_static :partial => 'extensions', :layout => 'echosocial'
  end

  # About
  def about
    render_outer_menu :partial => 'about', :layout => 'echosocial', :locals => {:title => I18n.t('static.echosocial.about.title')}
  end

  # Imprint
  def imprint
    render_outer_menu :partial => 'imprint', :layout => 'echosocial', :locals => {:title => I18n.t('static.echosocial.imprint.title')}
  end

  # Data privacy
  def data_privacy
    render_outer_menu :partial => 'data_privacy', :layout => 'echosocial', :locals => {:title => I18n.t('static.echosocial.data_privacy.title')}
  end
end
