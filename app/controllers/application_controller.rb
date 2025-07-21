# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Configuração de CSRF:
  # 'with: :null_session' para requisições JSON (vindas do seu frontend React/Next.js).
  # Isso significa que o Rails não espera um token CSRF para essas requisições.
  # 'unless: -> { request.format.json? }' faz com que a proteção CSRF padrão (com token)
  # continue ativa para requisições HTML (formulários Rails tradicionais).
  protect_from_forgery with: :null_session, unless: -> { request.format.json? }

  # >>> CORREÇÃO CRUCIAL AQUI: REMOVA A LINHA ABAIXO <<<
  # include Devise::Controllers::Helpers
  # Removemos esta linha e a dependência direta dos helpers Devise
  # para contornar o "NoMethodError" usando 'warden.authenticate' diretamente.


  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # Estas configurações são para o Devise, permitindo que certos atributos
    # sejam salvos quando um usuário se registra (sign_up) ou atualiza a conta (account_update).
    # O ':login' é adicionado para a sanitização de parâmetros no sign_in.
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: [:login, :password]
  end

  private

  def after_sign_in_path_for(resource)
    # Este método é um helper do Devise.
    # Ele define para onde o usuário será redirecionado APÓS um login BEM-SUCEDIDO
    # no lado do Rails (especialmente para requisições HTML).
    if resource.admin?
      '/admin/dashboard'
    else
      root_path
    end
  end
end