# Caminho: app/controllers/pages_controller.rb
class PagesController < ApplicationController
  # Esta é uma classe de controller simples para renderizar páginas estáticas,
  # como a página de erro para links inválidos.

  ##
  # Exibe a página de erro para links inválidos.
  #
  # Descrição: Esta ação é responsável por renderizar uma view estática
  #    que informa ao usuário que o link acessado é inválido ou expirou.
  # Argumentos: Nenhum.
  # Retorno: Renderiza a template `link_invalido.html.erb` (localizada em `app/views/pages/link_invalido.html.erb`).
  #    Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def link_invalido
    # Esta ação renderizará a view correspondente em app/views/pages/link_invalido.html.erb
  end
end
