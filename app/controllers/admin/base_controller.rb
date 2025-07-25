# Esta classe Admin::BaseController é a base para todas as ações administrativas
class Admin::BaseController < ApplicationController
  # Usa os helpers padrão do Devise para autenticação baseada em cookie/sessão.

  ##
  # Garante que qualquer usuário esteja logado antes de executar as ações do controlador.
  #
  # Descrição: Este `before_action` é fornecido pelo Devise e verifica se há um
  #    usuário autenticado. Se não houver, ele redireciona o usuário para a página
  #    de login configurada pelo Devise.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Redireciona internamente se a autenticação falhar.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para a página de login se o usuário não estiver autenticado.
  #    - Interrupção do fluxo da requisição se o usuário não estiver logado.
  before_action :authenticate_usuario!

  ##
  # Verifica se o usuário autenticado possui privilégios de administrador.
  #
  # Descrição: Este `before_action` personalizado é executado após a autenticação
  #    do usuário. Ele verifica o status de administrador do `current_usuario`
  #    e, se o usuário não for um administrador, impede o acesso e o redireciona.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Redireciona internamente se o usuário não for admin.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `root_path` se o usuário não for admin.
  #    - Exibição de mensagens flash: Define uma mensagem de alerta (`flash[:alert]`)
  #      informando sobre o acesso não autorizado.
  #    - Interrupção do fluxo da requisição se o usuário não tiver privilégios de administrador.
  before_action :check_admin_privileges

  private

  ##
  # Método auxiliar para verificar os privilégios de administrador do usuário atual.
  #
  # Descrição: Este método é chamado como um `before_action` para garantir que apenas
  #    usuários com o papel de administrador possam acessar as ações do controlador.
  #    Ele verifica a propriedade `admin?` do `current_usuario`.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `root_path` se `current_usuario.admin?` for falso.
  #    - Exibição de mensagens flash: Define `flash[:alert]` com uma mensagem de erro.
  def check_admin_privileges
    # Se o usuário logado (current_usuario) não for admin,
    # ele é redirecionado para a página inicial com um alerta.
    unless current_usuario.admin?
      flash[:alert] = "Acesso não autorizado. Você não tem permissão de administrador."
      redirect_to root_path
    end
  end
end
