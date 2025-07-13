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

  get 'definir-senha', to: 'password_resets#edit', as: 'definir_senha'
  get 'erro-link-invalido', to: 'pages#link_invalido', as: 'erro_link_invalido'

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end