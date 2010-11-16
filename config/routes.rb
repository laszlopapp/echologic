#
# Rails routing guide: http://guides.rubyonrails.org/routing.html
#
ActionController::Routing::Routes.draw do |map|

  # routing-filter plugin for wrapping :locale around urls and paths.
  map.filter :locale

  # SECTION main parts of echologic
  map.act '/act/roadmap', :controller => :act, :action => :roadmap
  map.discuss_featured '/discuss/featured', :controller => :discuss, :action => :index
  map.discuss_roadmap '/discuss/roadmap', :controller => :discuss, :action => :roadmap
  map.discuss_cancel '/discuss/cancel', :controller => :discuss, :action => :cancel
  map.my_discussions '/discuss/my_discussions', :controller => :discussions, :action => :my_discussions
  
  # SECTION discuss search
  map.discuss_search '/discuss/search', :controller => :discussions, :action => :category
  map.discuss_search_with_value '/discuss/search/:value', :controller => :discussions, :action => :category, :conditions => {:value => /\w+/ }
  
  # SECTION connect search
  map.connect_search '/connect/search', :controller => :connect, :action => :show
  map.connect_with_value '/connect/search/:value', :controller => :connect, :action => :show, :conditions => {:value => /\w+/ }
  map.connect_roadmap '/connect/roadmap', :controller => :connect, :action => :roadmap

  map.my_echo '/my_echo/roadmap', :controller => :my_echo, :action => :roadmap

  
#  map.resource :connect, :controller => 'connect', :only => [:show]
  map.resource :admin,   :controller => 'admin',   :only => [:show]

  # SECTION my echo routing
  map.my_profile 'my_profile', :controller => 'my_echo', :action => 'profile'

  map.resources :profiles, :controller => 'users/profile', :path_prefix => '', :only => [:show, :edit, :update]
  map.profile_details '/profiles/:id/details', :controller => 'users/profile', :action => 'details'

  map.welcome 'welcome', :controller => 'my_echo', :action => 'welcome'
  map.settings 'settings', :controller => 'my_echo', :action => 'settings'

  # SECTION autocomplete
  map.auto_complete ':controller/:action',
    :requirements => { :action => /auto_complete_for_\S+/ },
    :conditions => { :method => :get }

  # Not being logged in
  map.requires_login 'requires_login', :controller => 'application', :action => 'flash_info'

  # SECTION i18n
  map.resources :locales, :controller => 'i18n/locales' do |locale|
    locale.resources :translations, :controller => 'i18n/translations'
  end
  map.translations '/translations', :controller => 'i18n/translations', :action => 'translations'
  map.asset_translations '/asset_translations', :controller => 'i18n/translations', :action => 'asset_translations'
  map.filter_translations 'translations/filter', :controller => 'i18n/translations', :action => 'filter'

  #SECTION tags

  map.tags 'tags/:action/:id', :controller => :tags, :action => :index, :id => ''

  # SECTION feedback
  map.resources :feedback, :only => [:new, :create]
  # SECTION newsletter
  map.resources :newsletter, :only => [:new, :create]

  # SECTION user signup and login
  map.resource  :user_session, :controller => 'users/user_sessions',
                :path_prefix => '', :only => [:new, :create, :destroy]

  map.resources :users, :controller => 'users/users', :path_prefix => '' do |user|
    user.resources :web_addresses, :controller => 'users/web_addresses', :except => [:index]
    user.resources :spoken_languages, :controller => 'users/spoken_languages', :except => [:index]
    user.resources :activities,   :controller => 'users/activities',   :except => [:index]
    user.resources :memberships,  :controller => 'users/memberships',  :except => [:index]
  end
  #map.resources :tao_tags, :controller => 'tao_tags', :except => [:index]

  map.resources :password_resets, :controller => 'users/password_resets',
                :path_prefix => '', :except => [:destroy]

  map.register  '/register/:activation_code', :controller => 'users/activations', :action => 'new'
  map.join      '/join',                      :controller => 'users/users',       :action => 'new'
  map.activate  '/activate/:id',              :controller => 'users/activations', :action => 'create'

  map.resources :reports, :controller => 'users/reports'

  map.resources :about_items, :controller => 'about_items', :active_scaffold => true



  # SECTION static - contents per controller
  map.echo      'echo/:action',      :controller => 'static/echo',      :action => 'show'
  map.echonomy  'echonomy/:action',  :controller => 'static/echonomy',  :action => 'show'
  map.echocracy 'echocracy/:action', :controller => 'static/echocracy', :action => 'show'
  map.echologic 'echologic',         :controller => 'static/echologic', :action => 'show'
  map.static    'echologic/:action', :controller => 'static/echologic'


  # echo-social routes
  map.echosocial ':action',
                 :controller => 'static/echosocial',:action => 'show',
                 :conditions=>{:rails_env => 'development', :host =>'localhost', :port => 3001 }
  map.echosocial ':action',
                 :controller => 'static/echosocial',:action => 'show',
                 :conditions=>{:rails_env => 'staging', :host => "echosocial.echo-test.org" }
  map.echosocial ':action',
                 :controller => 'static/echosocial',:action => 'show',
                 :conditions=>{:rails_env => 'production', :host => "www.echosocial.org" }
  map.echosocial ':action',
                 :controller => 'static/echosocial',:action => 'show',
                 :conditions=>{:rails_env => 'production', :host => "echosocial.org" }
  map.echosocial ':action',
                 :controller => 'static/echosocial',:action => 'show',
                 :conditions=>{:rails_env => 'production', :host => "echosocial-prod-clone.echo-test.org" }


  # SECTION discuss - discussion tree
  map.add_discussion '/add_discussion', :controller => :discussions, :action => :add_discussion
  map.resources :discussions,
                :member => [:new_translation, :create_translation, :publish, :cancel, :more, :children, :upload_image, 
                            :reload_image, :authors, :add_proposal],
                :as => 'discussion'
  map.resources :proposals,
                 :member => [:echo, :unecho, :new_translation, :create_translation, :incorporate, :cancel, :more,
                             :children, :upload_image, :reload_image, :authors, :add_improvement_proposal],
                :as => 'proposal'
  map.resources :improvement_proposals,
                :member => [:echo, :unecho, :new_translation, :create_translation, :cancel, :upload_image, 
                            :reload_image, :authors],
                :as => 'improvement_proposal'
#  map.resources :arguments,
#                :member => [:echo, :unecho, :new_translation, :create_translation, :cancel, :upload_image, 
#                            :reload_image, :authors]
  map.resources :pro_arguments,
                :member => [:echo, :unecho, :new_translation, :create_translation, :cancel, :upload_image, :reload_image, :authors],
                :as => 'pro_argument'
  map.resources :contra_arguments,
                :member => [:echo, :unecho, :new_translation, :create_translation, :cancel, :upload_image, :reload_image, :authors],
                :as => 'contra_argument'
                
  # old discuss paths redirection
  map.connect 'discuss/questions/:discussion_id/proposals/:id', :controller => :proposals, :action => :redirect 
  map.connect 'discuss/questions/:discussion_id/proposals/:proposal_id/improvement_proposals/:id',
              :controller => :improvement_proposals, :action => :redirect 
              

  # SECTION root
  map.root :controller => 'static/echologic', :action => 'show'

  # SECTION default routes
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
