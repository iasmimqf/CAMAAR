Rails.application.routes.draw do
  devise_for :usuarios, controllers: {
    sessions: "usuarios/sessions"
  }
  get "home/index"

  resources :formularios, only: [ :index, :show ] do
    member do
      post :create_resposta
    end
  end

  namespace :admin do
    get "dashboard", to: "dashboard#index", as: "dashboard"
    post "importacoes/importar_turmas", to: "importacoes#importar_turmas"
    post "importacoes/importar_alunos", to: "importacoes#importar_alunos"
    resources :templates, only: [ :index, :create ]
    resources :formularios do
      collection do
        get :resultados
        post :gerar_csv
      end
    end
  end

  namespace :api do
    namespace :v1 do
      get "/sessions/current_user", to: "sessions#current_user"
      resources :formularios, only: [ :index ]
      resources :templates, only: [ :index, :create, :show, :update, :destroy ]
      post "password", to: "passwords#forgot"
      put "password", to: "passwords#reset"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
