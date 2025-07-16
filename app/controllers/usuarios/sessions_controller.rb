class Usuarios::SessionsController < Devise::SessionsController
  # Desabilita a proteção CSRF para a ação de 'create' (login via API)
  protect_from_forgery with: :null_session, only: [:create]
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: 'Logged in successfully.' },
      data: resource # Você pode customizar o que retorna aqui
    }, status: :ok
  end

  def respond_to_on_destroy
    head :no_content
  end
end
