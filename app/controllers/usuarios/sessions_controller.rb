# app/controllers/usuarios/sessions_controller.rb
class Usuarios::SessionsController < Devise::SessionsController
  # REMOVA QUALQUER LINHA 'include Devise::Controllers::Helpers' OU 'extend Devise::Controllers::Helpers' AQUI.

  respond_to :json

  # POST /usuarios/sign_in (Este método já usa warden.authenticate! e está OK)
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    render json: { data: resource_data }, status: :ok
  rescue Warden::Authentication::Failure
    render json: { error: 'Login ou senha inválidos.' }, status: :unauthorized
  end

  # DELETE /usuarios/sign_out
  def destroy
    # >>> MUDANÇA CRUCIAL AQUI: Faz o logout explicitamente <<<
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    if signed_out
      render json: { message: 'Logout bem-sucedido.' }, status: :ok
    else
      # Se não conseguiu fazer logout (ex: sessão já expirada/inválida), retorna 401
      render json: { error: 'Nenhum utilizador para fazer logout ou sessão inválida.' }, status: :unauthorized
    end
  end

  private

  def resource_data
    # Assumindo que 'resource' aqui já é o usuário autenticado pelo Devise.
    { id: resource.id, email: resource.email, admin: resource.admin? }
  end

  def respond_to_on_destroy
    # A resposta JSON já foi enviada no método destroy.
  end
end