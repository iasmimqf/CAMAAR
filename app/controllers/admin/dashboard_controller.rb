class Admin::DashboardController < ApplicationController
  ##
  # Garante que apenas usuários com privilégios de administrador possam acessar as ações deste controlador.
  #
  # Descrição: Este `before_action` verifica se o usuário autenticado é um administrador.
  #    Se o usuário não for um administrador, ele é redirecionado para a página inicial
  #    com uma mensagem de alerta.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Redireciona internamente se o usuário não for admin.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `root_path` se o usuário não for admin.
  #    - Exibição de mensagens flash: Define uma mensagem de alerta (`flash[:alert]`)
  #      informando sobre o acesso negado.
  #    - Interrupção do fluxo da requisição se o usuário não tiver privilégios de administrador.
  before_action :authenticate_admin!

  ##
  # Exibe a página principal do dashboard administrativo.
  #
  # Descrição: Esta ação é responsável por renderizar a view principal do dashboard.
  #    Atualmente, não contém lógica específica, mas pode ser estendida no futuro
  #    para buscar e exibir dados relevantes para o administrador.
  # Argumentos: Nenhum.
  # Retorno: Renderiza a template `index.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def index
    # Aqui você pode adicionar lógica no futuro,
    # como buscar dados para exibir no dashboard.
  end

  private

  ##
  # Método auxiliar para autenticar e verificar se o usuário é um administrador.
  #
  # Descrição: Este método é chamado como um `before_action` para proteger as ações
  #    deste controlador. Ele verifica se `current_usuario` existe e se possui
  #    o papel de administrador (`admin?`). Se qualquer uma dessas condições
  #    não for atendida, o usuário é redirecionado.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `root_path` se `current_usuario`
  #      não existir ou se `current_usuario.admin?` for falso.
  #    - Exibição de mensagens flash: Define `flash[:alert]` com uma mensagem de erro de acesso negado.
  def authenticate_admin!
    # Se o usuário atual não existir ou não for admin,
    # ele é redirecionado para a página inicial com uma mensagem de alerta.
    redirect_to root_path, alert: "Acesso negado. Você não é um administrador." unless current_usuario&.admin?
  end
end
class Admin::DashboardController < ApplicationController
  ##
  # Garante que apenas usuários com privilégios de administrador possam acessar as ações deste controlador.
  #
  # Descrição: Este `before_action` verifica se o usuário autenticado é um administrador.
  #    Se o usuário não for um administrador, ele é redirecionado para a página inicial
  #    com uma mensagem de alerta.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Redireciona internamente se o usuário não for admin.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `root_path` se o usuário não for admin.
  #    - Exibição de mensagens flash: Define uma mensagem de alerta (`flash[:alert]`)
  #      informando sobre o acesso negado.
  #    - Interrupção do fluxo da requisição se o usuário não tiver privilégios de administrador.
  before_action :authenticate_admin!

  ##
  # Exibe a página principal do dashboard administrativo.
  #
  # Descrição: Esta ação é responsável por renderizar a view principal do dashboard.
  #    Atualmente, não contém lógica específica, mas pode ser estendida no futuro
  #    para buscar e exibir dados relevantes para o administrador.
  # Argumentos: Nenhum.
  # Retorno: Renderiza a template `index.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def index
    # Aqui você pode adicionar lógica no futuro,
    # como buscar dados para exibir no dashboard.
  end

  private

  ##
  # Método auxiliar para autenticar e verificar se o usuário é um administrador.
  #
  # Descrição: Este método é chamado como um `before_action` para proteger as ações
  #    deste controlador. Ele verifica se `current_usuario` existe e se possui
  #    o papel de administrador (`admin?`). Se qualquer uma dessas condições
  #    não for atendida, o usuário é redirecionado.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `root_path` se `current_usuario`
  #      não existir ou se `current_usuario.admin?` for falso.
  #    - Exibição de mensagens flash: Define `flash[:alert]` com uma mensagem de erro de acesso negado.
  def authenticate_admin!
    # Se o usuário atual não existir ou não for admin,
    # ele é redirecionado para a página inicial com uma mensagem de alerta.
    redirect_to root_path, alert: "Acesso negado. Você não é um administrador." unless current_usuario&.admin?
  end
end
