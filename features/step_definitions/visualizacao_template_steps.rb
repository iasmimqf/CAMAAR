# Caminho: features/step_definitions/visualizacao_template_steps.rb

# --- DADOS BASE ---

##
# Dado: Existem os seguintes templates.
#
# Descrição: Cria múltiplos templates de formulário no banco de dados,
#    com os nomes fornecidos em uma string separada por vírgulas.
#    Cada template é associado a um criador (administrador) e recebe uma
#    questão de exemplo para satisfazer as validações.
# Argumentos:
#    - `templates_string` (String): Uma string contendo os nomes dos templates, separados por vírgulas.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Cria registros de `Template` e `Questao` no banco de dados.
Dado('existem os seguintes templates: {string}') do |templates_string|
  # Parse a string de templates separados por vírgula
  template_names = templates_string.split(',').map(&:strip)

  # Cria os templates
  template_names.each do |nome|
    # Usa @admin ou @admin_user dependendo de qual está definido
    criador = @admin || @admin_user
    template = create(:template, titulo: nome, criador: criador)
    # Adiciona uma questão para satisfazer a validação
    create(:questao, template: template, enunciado: 'Questão de exemplo', tipo: 'Texto')
  end
end

##
# Dado: Que ainda não existam templates cadastrados no sistema.
#
# Descrição: Remove todos os registros de `Template` do banco de dados,
#    garantindo um estado limpo onde nenhum template está presente para o teste.
#    Preserva o usuário logado.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Exclui todos os registros da tabela `templates`.
Dado('que ainda não existam templates cadastrados no sistema') do
  # Limpa todos os templates existentes, mas preserva o usuário logado
  Template.destroy_all
end

# --- QUANDO ---

##
# Quando: Eu acesso a página.
#
# Descrição: Navega para a página especificada pelo nome. Se o usuário não
#    estiver autenticado, tenta realizar o login programaticamente antes de
#    visitar a página novamente.
# Argumentos:
#    - `nome_pagina` (String): O nome da página para a qual navegar (e.g., 'Gerenciamento - Templates').
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Altera a página atual do navegador simulado.
#    - Pode realizar um login POST se o usuário não estiver autenticado.
#    - Pode levantar uma exceção se o nome da página for desconhecido.
Quando('eu acesso a página de {string}') do |nome_pagina|
  case nome_pagina
  when 'Gerenciamento - Templates'
    visit admin_templates_path

    # Se não estamos autenticados, faz login
    if page.has_content?('Para continuar, faça login') || page.has_content?('Log in')
      user = @admin_user || @admin
      if user
        page.driver.post usuario_session_path, {
          'usuario[login]' => user.email,
          'usuario[password]' => 'password123'
        }
        visit admin_templates_path
      end
    end
  else
    raise "Página #{nome_pagina} não reconhecida"
  end
end

# --- ENTÃO ---

##
# Então: Devo ver uma lista contendo.
#
# Descrição: Verifica se a página exibe uma lista de templates com os nomes
#    fornecidos em uma string separada por vírgulas.
# Argumentos:
#    - `templates_string` (String): Uma string contendo os nomes dos templates esperados, separados por vírgulas.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('devo ver uma lista contendo {string}') do |templates_string|
  template_names = templates_string.split(',').map(&:strip)

  template_names.each do |nome|
    expect(page).to have_content(nome)
  end
end

##
# Então: Cada template da lista deve conter os botões.
#
# Descrição: Verifica se cada elemento que representa um template na página
#    contém os botões (links) de "Editar" e "Excluir" especificados.
# Argumentos:
#    - `botao1` (String): O texto do primeiro botão (e.g., "Editar").
#    - `botao2` (String): O texto do segundo botão (e.g., "Excluir").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('cada template da lista deve conter os botões {string} e {string}') do |botao1, botao2|
  # Verifica se existem templates na página
  templates = page.all('.template-item, .bg-white, .border')

  # Se não encontrar pela classe, procura por linhas da tabela ou cards
  if templates.empty?
    templates = page.all('tr').select { |tr| tr.has_link?('Editar') || tr.has_link?('Excluir') }
  end

  # Se ainda não encontrou, procura pelos itens da lista
  if templates.empty?
    templates = page.all('li').select { |li| li.has_link?('Editar') || li.has_link?('Excluir') }
  end

  expect(templates.count).to be > 0, "Nenhum template foi encontrado na página"

  templates.each do |template_element|
    within(template_element) do
      expect(page).to have_link(botao1)
      expect(page).to have_link(botao2)
    end
  end
end

##
# Então: Devo ver uma mensagem como.
#
# Descrição: Verifica a presença de uma mensagem específica na página.
#    Inclui uma lógica para lidar com mensagens de "Nenhum template" de forma flexível.
# Argumentos:
#    - `mensagem` (String): O texto da mensagem esperada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('devo ver uma mensagem como {string}') do |mensagem|
  # Permite flexibilidade na mensagem exata
  if mensagem.include?("Nenhum template")
    expect(page).to have_content("Nenhum template")
  else
    expect(page).to have_content(mensagem)
  end
end

##
# Então: Não deve haver botões exibidos.
#
# Descrição: Verifica que não há links (botões) com os textos especificados
#    na página, confirmando que certas ações não estão disponíveis.
# Argumentos:
#    - `botao1` (String): O texto do primeiro botão que não deve estar presente.
#    - `botao2` (String): O texto do segundo botão que não deve estar presente.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('não deve haver botões {string} ou {string} exibidos') do |botao1, botao2|
  expect(page).not_to have_link(botao1)
  expect(page).not_to have_link(botao2)
end
