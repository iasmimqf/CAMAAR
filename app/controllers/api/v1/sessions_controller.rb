# app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < Api::V1::BaseController
  # O `before_action :authenticate_usuario!` que definimos no BaseController
  # já é executado antes de qualquer ação aqui. Ele cuida de toda a
  # validação do token JWT enviado no cabeçalho da requisição.

  # GET /api/v1/sessions/current_user
  def current_user
    # Se o código chegou até aqui, significa que o `authenticate_usuario!`
    # foi bem-sucedido e o `current_usuario` já está disponível e é válido.
    # Nós apenas precisamos retorná-lo em formato JSON.
    render json: {
      user: {
        id: current_usuario.id,
        email: current_usuario.email,
        admin: current_usuario.admin?
      }
    }, status: :ok
  end
end