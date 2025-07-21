# Esta classe Admin::BaseController é a base para todas as ações administrativas
class Admin::BaseController < ApplicationController
  # Requer autenticação e privilégios de administrador
  
  prepend_before_action :authenticate_admin_access!

  private

  def authenticate_admin_access!
    authenticated_user = warden.authenticate(scope: :usuario)
    handle_unauthorized(authenticated_user)
  end
  
  def handle_unauthorized(user)
    return if user&.admin?
    
    if json_request?
      render json: { error: 'Acesso não autorizado. Requer privilégios de administrador.' }, 
             status: :forbidden
    else
      flash[:alert] = "Acesso não autorizado."
      redirect_to root_path
    end
  end

  def json_request?
    request.format.json?
  end
end