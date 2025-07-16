class Usuarios::SessionsController < Devise::SessionsController
  # Desabilita a proteção CSRF para a ação de 'create' (login via API)
  skip_before_action :verify_authenticity_token

  # Este método irá interceptar a requisição POST /usuarios/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    
    # Resposta de SUCESSO customizada
    render json: {
      status: { code: 200, message: 'Login bem-sucedido.' },
      data: {
        id: resource.id,
        email: resource.email,
        admin: resource.admin? # Adiciona a flag de admin que o frontend precisa
      }
    }, status: :ok
  
  # Este 'rescue' é acionado se a autenticação do warden falhar
  rescue Warden::Authentication::Failure
    # Resposta de FALHA customizada
    render json: {
      status: { code: 401, message: 'Login ou senha inválidos.' },
      error: 'Login ou senha inválidos.' # Mensagem que o frontend vai exibir
    }, status: :unauthorized
  end

  # Seu método de logout já está perfeito, vamos mantê-lo
  def respond_to_on_destroy
    head :no_content
  end
end