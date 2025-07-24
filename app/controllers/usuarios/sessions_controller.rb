# app/controllers/usuarios/sessions_controller.rb
class Usuarios::SessionsController < Devise::SessionsController
  # Esta linha é a chave para dizer ao controller que ele deve responder em JSON.
  respond_to :json

  private

  # Este método é chamado automaticamente pelo Devise após um login bem-sucedido.
  # A gem `devise-jwt` intercepta esta resposta e adiciona o token no cabeçalho.
  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: 'Login realizado com sucesso.' },
      data: {
        id: resource.id,
        email: resource.email,
        admin: resource.admin?
      }
    }, status: :ok
  end

  # Este método é chamado automaticamente pelo Devise após um logout.
  def respond_to_on_destroy
    # A gem `devise-jwt` já cuidou de invalidar o token.
    # Nós apenas confirmamos com uma mensagem de sucesso.
    if request.headers['Authorization'].present?
      render json: {
        status: 200,
        message: "Logout realizado com sucesso."
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Não foi possível encontrar uma sessão ativa."
      }, status: :unauthorized
    end
  end
end
