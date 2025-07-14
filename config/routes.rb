# config/routes.rb
Rails.application.routes.draw do
  devise_for :usuarios
  get "home/index"

  namespace :admin do
    # Isso cria a rota GET /admin/dashboard que aponta para a ação 'index'
    # do controller 'dashboard' dentro do módulo 'admin'
    get 'dashboard', to: 'dashboard#index' , as: 'dashboard'
    post 'importacoes/importar_turmas', to: 'importacoes#importar_turmas'
    
    # Rotas para gerenciamento de templates (para o painel ADMIN, HTML)
    resources :templates
    
    namespace :import do
      # Routes for importing Turmas
      resources :turmas, only: [:new, :create]

      # Routes for importing Alunos
      resources :alunos, only: [:new, :create]
    end
  end

  # --- NOVO BLOCO DE ROTAS DA API ABAIXO ---
  # Rotas para a API (para o frontend React)
  namespace :api do
    namespace :v1 do
      # Este `resources :templates` é para a API RESTful
      # Ele vai mapear para `Api::V1::TemplatesController`
      resources :templates, only: [:index, :create, :update, :destroy, :show] do
        # Se no futuro suas questões forem um recurso aninhado na API:
        # resources :questoes, only: [:index, :show, :create, :update, :destroy]
      end
    end
  end
  # --- FIM DO NOVO BLOCO DE ROTAS DA API ---


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end