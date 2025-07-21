# app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < ApplicationController
  # REMOVA QUALQUER LINHA 'include Devise::Controllers::Helpers' OU 'extend Devise::Controllers::Helpers' AQUI.
  # (Se você criou o devise_helpers_fix.rb, remova o bloco ActiveSupport.on_load também deste arquivo).

  def current_user
    # >>> MUDANÇA CRUCIAL AQUI: Tenta autenticar o usuário diretamente <<<
    # Isso tenta obter o usuário logado sem usar user_signed_in? ou current_usuario diretamente.
    # Warden é a camada de autenticação do Devise.
    user = warden.authenticate(scope: :usuario) # Tenta autenticar o usuário

    if user # Se um usuário foi autenticado (ou seja, a sessão é válida)
      render json: { user: { id: user.id, email: user.email, admin: user.admin? } }, status: :ok
    else
      # Se não autenticou, significa que não há usuário logado ou a sessão é inválida.
      render json: { error: 'Nenhum utilizador está atualmente logado.' }, status: :unauthorized
    end
  end
end