# config/routes.rb
Rails.application.routes.draw do
  # Esta linha agora usa os controllers PADRÃO do Devise, que funcionam corretamente.
  devise_for :usuarios

  # As suas outras rotas permanecem iguais.
  get "home/index"

  namespace :admin do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    namespace :import do
      resources :turmas, only: [:new, :create]
      resources :alunos, only: [:new, :create]
    end
  end

  # Mantemos a sua URL amigável, mas agora ela aponta para o controller correto do Devise.
  devise_scope :usuario do
    get 'definir-senha', to: 'devise/passwords#edit', as: 'definir_senha'
  end

  get 'erro-link-invalido', to: 'pages#link_invalido', as: 'erro_link_invalido'
  get "up" => "rails/health#show", as: :rails_health_check
  root to: "home#index"
end
