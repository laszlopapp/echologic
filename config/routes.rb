ActionController::Routing::Routes.draw do |map|

  map.with_options :controller => 'static_content' do |static|
    
    static.echologic 'echologic', :action => 'echologic'
    
    # echo - the platform
    static.echo 'echo', :action => 'echo'
    static.echo_discuss 'echo/discuss', :action => 'echo_discuss'
    static.echo_connect 'echo/connect', :action => 'echo_connect'
    static.echo_act 'echo/act', :action => 'echo_act'
    
    # echocracy
    static.echocracy 'echocracy', :action => 'echocracy'
    static.echocracy_citizens 'echocracy/citizens', :action => 'echocracy_citizens'
    static.echocracy_experts 'echocracy/experts', :action => 'echocracy_experts'
    static.echocracy_organisations 'echocracy/organisations', :action => 'echocracy_organisations'
    
    # echonomy
    static.echonomy 'echonomy', :action => 'echonomy'
    static.echonomy_business_model 'echonomy/business_model', :action => 'echonomy_business_model'
    static.echonomy_foundation 'echonomy/foundation', :action => 'echonomy_foundation'
    static.echonomy_public_property 'echonomy/public_property', :action => 'echonomy_public_property'
    
    # echo on waves
    static.echoonwaves 'echo_on_waves', :action => 'echo_on_waves'
    static.echoonwaves_win_win 'echo_on_waves/win_win', :action => 'echo_on_waves_win_win'
    static.echoonwaves_open_source 'echo_on_waves/open_source', :action => 'echo_on_waves_open_source'
    static.echoonwaves_joint_effort 'echo_on_waves/joint_effort', :action => 'echo_on_waves_joint_effort'
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => 'static_content', :action => 'echologic'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  
  #map.maininfo 'static_content/:menu', :controller => "static_content", :action => :menu
  #map.subinfo 'static_content/:menu/:submenu', :controller => "static_content", :action => :menu + "_" + :submenu 
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
