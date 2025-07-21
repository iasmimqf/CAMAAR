# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  # REMOVA QUALQUER LINHA 'include Devise::Controllers::Helpers' OU 'extend Devise::Controllers::Helpers' AQUI.

  prepend_before_action :authenticate_admin_access!

  private

  # Método para garantir que o usuário está logado E é um administrador.
  def authenticate_admin_access!
    # Tenta obter o usuário logado via Devise (Warden)
    authenticated_user = warden.authenticate(scope: :usuario)

    # 1. Primeiro, verifica se há um utilizador logado.
    unless authenticated_user # Se não há usuário autenticado
      if request.format.json?
        render json: { error: 'Você precisa estar autenticado para acessar este recurso.' }, status: :unauthorized and return
      else
        # Para pedidos HTML, redireciona manualmente (não podemos confiar em authenticate_usuario!)
        redirect_to new_usuario_session_path, alert: "Você precisa estar autenticado." and return
      end
    end

    # 2. Se o utilizador estiver autenticado, verifica se ele é um administrador.
    unless authenticated_user.admin? # Usa o usuário autenticado, não current_usuario
      if request.format.json?
        render json: { error: 'Acesso não autorizado. Requer privilégios de administrador.' }, status: :forbidden and return
      else
        flash[:alert] = "Acesso não autorizado."
        redirect_to root_path and return
      end
    end

    # Se chegar aqui, o usuário está autenticado E é um administrador.
    # Você pode querer definir @current_usuario aqui se outros métodos dependerem dele.
    # @current_usuario = authenticated_user
  end
end