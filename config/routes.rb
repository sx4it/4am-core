AM::Application.routes.draw do

  get "log" => "log#index"

  resources :new_user, :only=>[:new, :create]
  resources :host_acls, :only=>[:index, :create, :destroy]
  resources :roles, :only=>[:index, :create, :destroy]

  resources :user_groups

  resources :commands

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
    resources :cmd do
      collection do
          get :clear
      end
    end
  end

  resources :host_tpls

  resources :keys do
    member do
      get "pkcs12/new" => "keys#pkcs12_new"
      post "pkcs12" => "keys#pkcs12_create"
      get "x509"
    end
  end

  get "login" => "sessions#new", :as => "login"
  post "login" => "sessions#create"
  get "logout" => "sessions#destroy", :as => "logout"


  resources :users do
    member do
      get "keys" => "keys#index"
      post :reset_api_token
    end
  end
  root :to => 'dashboard#index'

end
