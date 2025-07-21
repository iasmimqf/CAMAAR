# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  # Esta é uma classe de controller simples para renderizar páginas estáticas,
  # como a página de erro para links inválidos.
  def link_invalido
    # Esta ação renderizará a view correspondente em app/views/pages/link_invalido.html.erb
  end
end
