class Static::EchosocialController < ApplicationController

  # Default page redirected to echoLogic - The Mission
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'echosocial' }
      format.js { render :template => 'layouts/tabContainer' }
    end
  end

  # echosocial - Features
  def features
    respond_to do |format|
      format.html { render :partial => 'features', :layout => 'echosocial' }
      format.js { render :template => 'layouts/tabContainer' }
    end
  end

  # echosocial - Benefits
  def extensions
    respond_to do |format|
      format.html { render :partial => 'extensions', :layout => 'echosocial' }
      format.js { render :template => 'layouts/tabContainer' }
    end
  end

  # About
  def about
    respond_to do |format|
      format.html { render :partial => 'about', :layout => 'echosocial', :locals => {:title => I18n.t('static.echosocial.about.title')} }
      format.js { render :template => 'layouts/outerMenuDialog', :locals => {:title => I18n.t('static.echosocial.about.title')} }
    end
  end

  # Imprint
  def imprint
    respond_to do |format|
      format.html { render :partial => 'imprint', :layout => 'echosocial', :locals => {:title => I18n.t('static.echosocial.imprint.title')} }
      format.js { render :template => 'layouts/outerMenuDialog', :locals => { :title => I18n.t('static.echosocial.imprint.title')} }
    end
  end

  # Data privacy
  def data_privacy
    respond_to do |format|
      format.html { render :partial => 'data_privacy', :layout => 'echosocial', :locals => { :title => I18n.t('static.echosocial.data_privacy.title')} }
      format.js { render :template => 'layouts/outerMenuDialog', :locals => { :title => I18n.t('static.echosocial.data_privacy.title')} }
    end
  end

end
