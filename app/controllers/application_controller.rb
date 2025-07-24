# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Esta linha protege contra ataques CSRF para requisições HTML,
  # mas ignora essa proteção para requisições JSON (da nossa API).
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  # Este 'before_action' é do Devise e deve continuar aqui.
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # Suas configurações estão corretas e devem ser mantidas.
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: [:login, :password]
  end

  private

  # Este método é para o "Mundo do Admin" (HTML) e está correto.
  def after_sign_in_path_for(resource)
    if resource.admin?
      '/admin/dashboard'
    else
      root_path
    end
  end
end