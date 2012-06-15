Eip::Application.routes.draw do

  get "log" => "log#index"

  resources :new_user, :only=>[:new, :create]
  resources :host_acls, :only=>[:index, :create, :destroy]
  resources :roles, :only=>[:index, :create, :destroy]

  namespace :admin do
    resources :roles, :only=>[:index, :create, :destroy]
    resources :users do
      member do
        post :add_role
        delete :delete_role
      end
    end
  end

  resources :user_groups do
    member do
      get :add_user
      get :del_user
    end
  end

  resources :commands

  get :autocomplete_host_name, :controller => :autocomplete
  get :autocomplete_user_login, :controller => :autocomplete
  resources :hosts do
    resources :cmd do
      collection do
        get "clear"
      end
    end
  end

  resources :host_groups do
    member do
      get :add_host
      get :del_host
    end
    resources :cmd do
      collection do
          get :clear
      end
    end
  end

  resources :host_tpls

  resources :keys

  get "login" => "sessions#new", :as => "login"
  post "login" => "sessions#create"
  get "logout" => "sessions#destroy", :as => "logout"


  resources :users do
    member do
      get :keys
      post :add_role
      delete :delete_role
    end
  end
  root :to => 'dashboard#index'

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
  # match ':controller(/:action(/:id(.:format)))'
end
