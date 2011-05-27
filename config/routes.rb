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
  map.my_questions '/discuss/my_questions', :controller => :statements, :action => :my_questions

  # SECTION discuss search
  map.discuss_search '/discuss/search', :controller => :statements, :action => :category

  # SECTION connect search
  map.connect_search '/connect/search', :controller => :connect, :action => :show
  map.connect_roadmap '/connect/roadmap', :controller => :connect, :action => :roadmap

  map.my_echo '/my_echo/roadmap', :controller => :my_echo, :action => :roadmap

  map.resource :admin,   :controller => 'admin',   :only => [:show]

  # SECTION my echo routing
  map.my_profile 'my_profile', :controller => 'my_echo', :action => 'profile'

  map.resources :profiles, :controller => 'users/profiles', :path_prefix => '', :only => [:show, :edit, :update]
  map.profile_details '/profiles/:id/details', :controller => 'users/profiles', :action => 'details'

  map.welcome 'welcome', :controller => 'my_echo', :action => 'welcome'
  map.settings 'settings', :controller => 'my_echo', :action => 'settings'

  # SECTION autocomplete
  map.auto_complete ':controller/:action',
    :requirements => { :action => /auto_complete_for_\S+/ },
    :conditions => { :method => :get }

  # AUTO COMPLETE FOR statements title TODO: WHY DOES THE PREVIOUS ROUTE DOES NOT WORK?????
  map.connect 'statements/auto_complete_for_statement_title', :controller => :statements, :action => :auto_complete_for_statement_title
  
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


  # SECTION user signup and login
  map.resources  :user_sessions, :controller => 'users/user_sessions',
                 :path_prefix => ''


  map.resources :users, :controller => 'users/users', :path_prefix => '' do |user|
    user.resources :web_addresses, :controller => 'users/web_addresses', :except => [:index]
    user.resources :spoken_languages, :controller => 'users/spoken_languages', :except => [:index]
    user.resources :activities,   :controller => 'users/activities',   :except => [:index]
    user.resources :memberships,  :controller => 'users/memberships',  :except => [:index]
  end

  map.resources :password_resets, :controller => 'users/password_resets', :path_prefix => '', :except => [:destroy]

  map.register   '/register/:activation_code', :controller => 'users/activations', :action => 'basic_profile'
  map.activate   '/activate/:activation_code', :controller => 'users/activations', :action => 'activate', :method => :post
  map.signin     '/signin',                    :controller => 'users/user_sessions', :action => 'new'
  map.signup     '/signup',                    :controller => 'users/users',       :action => 'new'
  map.signout    '/signout',                   :controller => 'users/user_sessions', :action => 'destroy'
  map.setup_basic_profile '/setup_basic_profile/:activation_code', :controller => 'users/users', :action => 'setup_basic_profile'
  map.pending_action '/pending_action/:token', :controller => 'users/activations', :action => 'activate_email'

  # Social Accout Routes
  map.signin_remote '/signin_remote',          :controller => 'users/user_sessions', :action => 'create_social', :method => :post
  map.signup_remote '/signup_remote',          :controller => 'users/users',       :action => 'create_social', :method => :post
  map.add_remote    '/add_remote/',            :controller => 'users/users', :action => 'add_social', :method => :post
  map.remove_remote '/remove_remote/:provider',:controller => 'users/users', :action => 'remove_social', :method => :put

  map.redirect_from_popup '/redirect_from_popup', :controller => 'application', :action => 'redirect_from_popup', :method => :post


  map.resources :reports, :controller => 'users/reports'
  map.resources :about_items, :controller => 'about_items', :active_scaffold => true
  map.resources :newsletters


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


  # SECTION discuss - statement's tree

  #route for new question
  map.new_question         'statement/new/question', :controller => :statements, :action => :new, :type => :question

  #Add Teaser section
  map.add_question_teaser  'statement/add/question', :controller => :statements, :action => :add, :type => :question
  map.add_teaser  'statement/:id/add/:type', :controller => :statements, :action => :add
   
  map.question_descendants 'statement/descendants/question/', :controller => :statements, :action => :descendants, :type => :question

  map.resources :statement_nodes, :controller => :statements,
                :member => [:echo, :unecho, :new_translation, :create_translation, :cancel, :social_widget, #:add,
                            :children, :more, :authors, :publish, :incorporate, :ancestors, :descendants, :share],
                :path_names => { :new => ':id/new/:type', :more => 'more/:type',# :add => ':id/add/:type',
                                 :edit => 'edit/:current_document_id', :new_translation => 'translation/:current_document_id',
                                 :children => 'children/:type', :incorporate => 'incorporate/:approved_ip',
                                 :descendants => 'descendants/:type/'},
                :as => 'statement'
  #publish
  map.publish_statement   'statement/:id/publish/:in',   :controller => :statements, :action => :publish, :method => :put
  map.connect   'statement/link_statement/:id', :controller => :statements, :action => :link_statement

  map.with_options(:path_prefix => ":type/:action") do |m|
    m.resources :questions, :controller => :statements, :only => [:create]
    m.resources :proposals, :controller => :statements, :only => [:create]
    m.resources :improvements, :controller => :statements, :only => [:create]
    m.resources :pro_arguments, :controller => :statements, :only => [:create]
    m.resources :contra_arguments, :controller => :statements, :only => [:create]
    m.resources :follow_up_questions, :controller => :statements, :only => [:create]
    m.resources :background_infos, :controller => :statements, :only => [:create]
  end
  
  map.resources :questions, :controller => :statements, :only => [:update]
  map.resources :proposals, :controller => :statements, :only => [:update]
  map.resources :improvements, :controller => :statements, :only => [:update]
  map.resources :pro_arguments, :controller => :statements, :only => [:update]
  map.resources :contra_arguments, :controller => :statements, :only => [:update]
  map.resources :follow_up_questions, :controller => :statements, :only => [:update]
  map.resources :background_infos, :controller => :statements, :only => [:update]

  #statement images
  map.resources :statement_images,
                :member => [:reload], :only => [:edit, :update],
                :path_names => {:edit => 'statement/:node_id/edit',
                                :reload => 'statement/:node_id/reload'}, :as => 'image'


  # old discuss paths redirection
  map.connect 'discuss/questions/:question_id/proposals/:id', :controller => :statements, :action => :redirect_to_statement
  map.connect 'discuss/questions/:question_id/proposals/:proposal_id/improvement_proposals/:id',
              :controller => :statements, :action => :redirect_to_statement

  # SECTION root
  map.root :controller => 'static/echologic', :action => 'show'


  # SECTION default routes
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  # SECTION shortcut urls
  map.shortcut ':shortcut', :controller => :application, :action => :shortcut
end
