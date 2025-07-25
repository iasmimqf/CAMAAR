# Caminho: app/controllers/api/v1/sessions_controller.rb

class Api::V1::SessionsController < Api::V1::BaseController
  # O `before_action :authenticate_usuario!` que definimos no BaseController
  # já é executado antes de qualquer ação aqui. Ele cuida de toda a
  # validação do token JWT enviado no cabeçalho da requisição.

  ##
  # Retorna os detalhes do usuário autenticado atualmente.
  #
  # Descrição: Esta ação é um endpoint da API que, após a autenticação bem-sucedida
  #    do usuário (garantida pelo `Api::V1::BaseController`), retorna as informações
  #    básicas do `current_usuario` em formato JSON.
  # Argumentos: Nenhum.
  # Retorno:
  #    - `JSON`: Retorna um objeto JSON contendo o `id`, `email` e o status `admin`
  #      do usuário autenticado, com status `:ok` (200).
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados.
  #    - Comunicação via API: Envia uma resposta JSON ao cliente.
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
