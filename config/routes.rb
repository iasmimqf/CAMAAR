Rails.application.routes.draw do
  devise_for :usuarios
  get "home/index"

  namespace :admin do
    # Isso cria a rota GET /admin/dashboard que aponta para a ação 'index'
    # do controller 'dashboard' dentro do módulo 'admin'
    get 'dashboard', to: 'dashboard#index' , as: 'dashboard'
    post 'importacoes/importar_turmas', to: 'importacoes#importar_turmas'
    namespace :import do
      # Routes for importing Turmas
      resources :turmas, only: [:new, :create]

      # Routes for importing Alunos
      resources :alunos, only: [:new, :create]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end