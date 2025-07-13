# config/routes.rb
Rails.application.routes.draw do
  devise_for :usuarios, controllers: {
    passwords: 'password_resets' # Aponta para app/controllers/password_resets_controller.rb
  }

  get "home/index"

  namespace :admin do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    namespace :import do
      resources :turmas, only: [:new, :create]
      resources :alunos, only: [:new, :create]
    end
  end

  # --- ALTERAÇÃO AQUI: Envolver a rota customizada em devise_scope ---
  devise_scope :usuario do # O nome do seu mapeamento Devise (singular, minúsculo)
    get 'definir-senha', to: 'password_resets#edit', as: 'definir_senha'
    # Se você precisar submeter o formulário para este controller customizado,
    # também adicione as rotas PATCH/PUT dentro deste bloco:
    # patch 'definir-senha', to: 'password_resets#update'
    # put 'definir-senha', to: 'password_resets#update'
  end
  # --- FIM DA ALTERAÇÃO ---

  get 'erro-link-invalido', to: 'pages#link_invalido', as: 'erro_link_invalido'

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end