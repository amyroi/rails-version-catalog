Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :catalog do
        resources :versions, only: :index
        resources :features, only: [ :index, :show ], param: :slug
      end
    end
  end

  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, only: [ :new, :create, :edit, :update ], param: :token
  resources :users, only: [ :new, :create ]
  resource :auth_lab, only: :show
  resources :features, only: [ :index, :show ], param: :slug
  resources :queue_runs, only: :create
  resources :demo_messages, only: :create
  resource :cache_demo, only: [], controller: :cache_demos do
    post :refresh
    delete :destroy
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#show"
end
