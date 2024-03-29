SlenderRay::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  root :to => 'static_pages#home'

  devise_for :users
  resources :users, :only => [:index]
  
  resources :treatment_facilities do
    member do
      get 'edit_assignments'
      put 'update_assignments'
      put 'update_dashboard'
      get 'treatment_areas'
    end
    
    get 'dashboard', :on => :collection
    get 'static_dashboard', :on => :collection
  end
  resources :patients do
    member do
      get 'current_session_machine'
      get 'completed_sessions'
      get 'treat'
    end
  end
  resources :testimonials
  resources :treatment_sessions do
    member do
      put 'timer_expired'
      put 'treatment_expired'
      get 'edit_measurements'
      put 'update_measurements'
      get 'timer_state'
    end
  end
  resources :photos, :except => [:show]
  resources :protocols
  
  match "/training_videos" => 'static_pages#training_videos'
  match "/public_videos" => 'static_pages#public_videos'
  match "/select_report" => 'static_pages#select_report'
  match "/generate_report" => 'static_pages#generate_report', :via => :post
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
