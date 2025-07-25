# Caminho: app/controllers/usuarios/sessions_controller.rb
class Usuarios::SessionsController < Devise::SessionsController
  # Esta linha é a chave para dizer ao controller que ele deve responder em JSON.
  respond_to :json

  private

  ##
  # Lida com a resposta após um login bem-sucedido.
  #
  # Descrição: Este método é um callback do Devise, chamado automaticamente após
  #    um usuário fazer login com sucesso. Ele formata a resposta JSON para
  #    incluir o status do login e os dados do usuário (id, email, admin).
  #    A gem `devise-jwt` intercepta esta resposta para adicionar o token JWT
  #    no cabeçalho da requisição.
  # Argumentos:
  #    - `resource`: O objeto do recurso (usuário) que acabou de fazer login.
  #    - `_opts`: Opções adicionais (ignoradas neste contexto).
  # Retorno:
  #    - `JSON`: Retorna um JSON com `status` (código 200 e mensagem de sucesso)
  #      e `data` (id, email, admin do usuário), com status HTTP `:ok` (200).
  # Efeitos colaterais:
  #    - Comunicação via API: Envia uma resposta JSON ao cliente.
  #    - A `devise-jwt` adiciona o token JWT ao cabeçalho da resposta.
  # Este método é chamado automaticamente pelo Devise após um login bem-sucedido.
  # A gem `devise-jwt` intercepta esta resposta e adiciona o token no cabeçalho.
  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: "Login realizado com sucesso." },
      data: {
        id: resource.id,
        email: resource.email,
        admin: resource.admin?
      }
    }, status: :ok
  end

  ##
  # Lida com a resposta após um logout.
  #
  # Descrição: Este método é um callback do Devise, chamado automaticamente após
  #    um usuário fazer logout. Ele verifica a presença do cabeçalho de autorização
  #    para determinar se uma sessão ativa foi encontrada e retorna uma mensagem
  #    de sucesso ou falha apropriada em JSON. A gem `devise-jwt` já cuida da
  #    invalidação do token.
  # Argumentos: Nenhum.
  # Retorno:
  #    - `JSON`: Retorna um JSON com `status: 200` e uma `message` de sucesso
  #      com status HTTP `:ok` (200) se o logout for bem-sucedido.
  #    - `JSON`: Retorna um JSON com `status: 401` e uma `message` de erro
  #      com status HTTP `:unauthorized` (401) se nenhuma sessão ativa for encontrada.
  # Efeitos colaterais:
  #    - Comunicação via API: Envia uma resposta JSON ao cliente.
  # Este método é chamado automaticamente pelo Devise após um logout.
  def respond_to_on_destroy
    # A gem `devise-jwt` já cuidou de invalidar o token.
    # Nós apenas confirmamos com uma mensagem de sucesso.
    if request.headers["Authorization"].present?
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
