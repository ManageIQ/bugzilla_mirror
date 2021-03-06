require 'sidekiq/web'
require 'sidetiq/web'

BugzillaMirror::Application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"

  resources :dashboard do
    collection do
      get 'index'
      get 'reload_issues'
      get 'update_issues'
    end
  end

  resources :errata_reports do
    collection do
      get 'index'
    end
  end

  resources :statistics_reports do
    collection do
      get 'index'
    end
  end

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

  root :to => 'dashboard#index'
  get '/dashboard/view_issue(/:id)'         => 'dashboard#view_issue'
  get '/dashboard/refresh_issue(/:id)'      => 'dashboard#refresh_issue'

  get '/issues(.:format)'                   => 'issues#show',   :format => 'json'
  get '/issues(/:id)(.:format)'             => 'issues#show',   :format => 'json'
  get '/issues(/:action(/:id))(.:format)'   => 'issues#show',   :format => 'json'
  match '/issues(/:id)(.:format)'           => 'issues#update', :format => 'json', :via => [:post]
  match '/issues(/:action(/:id))(.:format)' => 'issues#update', :format => 'json', :via => [:post]

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
