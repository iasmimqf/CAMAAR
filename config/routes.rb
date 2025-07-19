# config/routes.rb
Rails.application.routes.draw do
  devise_for :usuarios, controllers: {
    sessions: 'usuarios/sessions'
  }
  get "home/index"

  # Rotas para alunos responderem formulários
  resources :formularios, only: [:index, :show] do
    member do
      post :create_resposta
    end
  end

  namespace :admin do
    # Isso cria a rota GET /admin/dashboard que aponta para a ação 'index'
    # do controller 'dashboard' dentro do módulo 'admin'
    get 'dashboard', to: 'dashboard#index' , as: 'dashboard'
    post 'importacoes/importar_turmas', to: 'importacoes#importar_turmas'
    
    # MODIFICADO: Rotas para gerenciamento de templates (para o painel ADMIN, HTML)
    # Removendo :edit, :show e :destroy para evitar conflitos com a API e garantir que
    # o frontend React controle essas ações.
    resources :templates, only: [:index, :create]
    # Se você não usa NADA HTML para templates, pode comentar a linha acima inteira:
    # # resources :templates
    
    # Rotas para gerenciamento de formulários
    resources :formularios do
      collection do
        get :resultados
        post :gerar_csv
      end
    end
    
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
      # Mantenha todos os métodos da API aqui, incluindo :show, :update, :destroy
      resources :templates, only: [:index, :create, :show, :update, :destroy] do
        # Se no futuro suas questões forem um recurso aninhado na API:
        # resources :questoes, only: [:index, :show, :create, :update, :destroy]
      end
      post 'password', to: 'passwords#forgot'
        # Rota para o usuário submeter a nova senha com o token.
      put 'password', to: 'passwords#reset'
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

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end