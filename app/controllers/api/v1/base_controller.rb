# Caminho: app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  # Desativa a proteção CSRF, o que é comum para APIs.
  skip_before_action :verify_authenticity_token

  ##
  # Garante que o usuário esteja autenticado para todas as requisições da API.
  #
  # Descrição: Este `before_action` é fornecido pelo Devise e verifica se há um
  #    usuário autenticado para qualquer rota da API. Se não houver, a requisição
  #    é bloqueada com um erro 401 (Unauthorized).
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Interrompe a requisição com status 401 se a autenticação falhar.
  # Efeitos colaterais:
  #    - Interrupção do fluxo da requisição se o usuário não estiver autenticado.
  #    - Retorno de resposta com status HTTP 401.
  # 1. AUTENTICAÇÃO:
  #    Esta linha garante que para QUALQUER rota da sua API,
  #    o Devise vai primeiro verificar se o usuário está logado.
  #    Se não estiver, a requisição é bloqueada com erro 401.
  before_action :authenticate_usuario!

  private

  ##
  # Garante que o usuário autenticado possui privilégios de administrador para acessar a API.
  #
  # Descrição: Este método verifica se o `current_usuario` (que já foi garantido como existente
  #    pelo `authenticate_usuario!`) possui o papel de administrador. Se o usuário não for
  #    um administrador, a requisição é bloqueada com um erro 403 (Forbidden).
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Interrompe a requisição com status 403 se a autorização falhar.
  # Efeitos colaterais:
  #    - Interrupção do fluxo da requisição se o usuário não tiver privilégios de administrador.
  #    - Retorno de resposta JSON com mensagem de erro e status HTTP 403.
  # 2. AUTORIZAÇÃO:
  #    Este método agora só se preocupa em verificar se o usuário é admin.
  #    Ele pode fazer isso com segurança, pois a linha acima já garantiu
  #    que `current_usuario` existe.
  def authenticate_admin_access!
    unless current_usuario.admin?
      render json: {
        error: "Acesso não autorizado. Requer privilégios de administrador."
      }, status: :forbidden
    end
  end
end
