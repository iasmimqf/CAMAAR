class ApplicationController < ActionController::Base
  # Configuração para autenticação com Devise
  
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  private
  def after_sign_in_path_for(resource)
    # 'resource' é o usuário que acabou de fazer login
    if resource.admin?
      '/admin/dashboard' # O caminho para o dashboard do admin
    else
      root_path # O caminho para a página inicial (/) para usuários normais
    end
  end

end
