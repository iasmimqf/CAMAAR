# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  # Desativa a proteção CSRF, o que é comum para APIs.
  skip_before_action :verify_authenticity_token

  # 1. AUTENTICAÇÃO:
  #    Esta linha garante que para QUALQUER rota da sua API,
  #    o Devise vai primeiro verificar se o usuário está logado.
  #    Se não estiver, a requisição é bloqueada com erro 401.
  before_action :authenticate_usuario!

  private

  # 2. AUTORIZAÇÃO:
  #    Este método agora só se preocupa em verificar se o usuário é admin.
  #    Ele pode fazer isso com segurança, pois a linha acima já garantiu
  #    que `current_usuario` existe.
  def authenticate_admin_access!
    unless current_usuario.admin?
      render json: {
        error: 'Acesso não autorizado. Requer privilégios de administrador.'
      }, status: :forbidden
    end
  end
end
