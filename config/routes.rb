Eip::Application.routes.draw do

  get "log" => "log#index"

  resources :new_user, :only=>[:new, :create]
  resources :host_acls, :only=>[:index, :create, :destroy]
  resources :roles, :only=>[:index, :create, :destroy]

  resources :user_groups do
    member do
      post :add_user
      delete :del_user
    end
  end

  resources :commands

  get :autocomplete_host_name, :controller => :autocomplete
  get :autocomplete_user_login, :controller => :autocomplete
  resources :hosts do
    resources :cmd do
      collection do
        delete "clear"
        get "refresh"
      end
      member do
        post "new"
      end
    end
  end

  resources :host_groups do
    member do
      post :add_host
      delete :del_host
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
      post :reset_api_token
    end
  end
  root :to => 'dashboard#index'

end
