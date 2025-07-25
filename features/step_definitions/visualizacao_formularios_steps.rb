# Caminho: features/step_definitions/visualizacao_formularios_steps.rb

# --- DADO ---

##
# Dado: Que eu esteja na página de formulários.
#
# Descrição: Navega para a página especificada, que pode ser o dashboard administrativo
#    ou outra página de formulários. Para o dashboard, tenta visitar a rota `admin_root_path`
#    ou `root_path` como fallback. Para outras páginas, apenas confirma que o administrador
#    está autenticado.
# Argumentos:
#    - `pagina` (String): O nome da página para a qual navegar (e.g., 'Gerenciamento').
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Altera a página atual do navegador simulado.
#    - Pode levantar uma exceção se o nome da página for desconhecido.
Dado('que eu esteja na página de formulários {string}') do |pagina|
  case pagina
  when 'Gerenciamento'
    visit admin_root_path rescue visit root_path
  else
    # Para outras páginas, apenas confirma que estamos logados
    expect(@admin).to be_present
  end
end

##
# Dado: Existem formulários criados a partir de templates existentes.
#
# Descrição: Cria templates de formulário, disciplinas e turmas. Em seguida,
#    cria formulários e os associa a esses templates e turmas, simulando
#    um cenário com dados preexistentes para visualização.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria registros de `Template`, `Questao`, `Disciplina`, `Turma` e `Formulario` no banco de dados.
#    - Define as variáveis de instância `@template1`, `@template2`, `@formulario1` e `@formulario2`.
Dado('existem formulários criados a partir de templates existentes') do
  # Usa @admin_user que é criado no step de autenticação
  admin_criador = @admin_user || @admin

  # Cria template primeiro com o admin logado
  @template1 = create(:template, titulo: 'Avaliação Docente', criador: admin_criador)
  create(:questao, template: @template1, enunciado: 'Como você avalia a disciplina?', tipo: 'Escala')

  @template2 = create(:template, titulo: 'Avaliação Infraestrutura', criador: admin_criador)
  create(:questao, template: @template2, enunciado: 'Como você avalia a infraestrutura?', tipo: 'Texto')

  # Cria disciplinas e turmas
  disciplina1 = create(:disciplina, nome: 'Programação Orientada a Objetos')
  disciplina2 = create(:disciplina, nome: 'Engenharia de Software')

  turma1 = create(:turma, codigo_turma: '001', disciplina: disciplina1)
  turma2 = create(:turma, codigo_turma: '002', disciplina: disciplina2)
  turma3 = create(:turma, codigo_turma: '003', disciplina: disciplina1)

  # Cria formulários com turmas associadas diretamente
  @formulario1 = Formulario.new(template: @template1, criador: admin_criador)
  @formulario1.turmas = [ turma1, turma2 ]
  @formulario1.save!

  @formulario2 = Formulario.new(template: @template2, criador: admin_criador)
  @formulario2.turmas = [ turma3 ]
  @formulario2.save!
end

##
# Dado: Que ainda não existam formulários criados no sistema.
#
# Descrição: Remove todos os registros de `Formulario` do banco de dados,
#    garantindo que nenhum formulário esteja presente para o cenário de teste.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Exclui todos os registros da tabela `formularios`.
Dado('que ainda não existam formulários criados no sistema') do
  Formulario.destroy_all
end

# --- QUANDO ---

##
# Quando: Eu acesso a página de resultados.
#
# Descrição: Navega para a página de resultados de formulários, que exibe
#    uma lista de formulários criados.
# Argumentos:
#    - `pagina` (String): O nome da página de resultados (e.g., 'Resultados').
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Altera a página atual do navegador simulado.
#    - Pode levantar uma exceção se o nome da página for desconhecido.
Quando('eu acesso a página de resultados {string}') do |pagina|
  case pagina
  when 'Resultados'
    visit resultados_admin_formularios_path
  else
    raise "Página '#{pagina}' não está mapeada nos step definitions"
  end
end

# --- ENTÃO ---

##
# Então: Devo ver uma tabela com os formulários criados.
#
# Descrição: Verifica a presença de uma tabela HTML na página,
#    confirmando que a estrutura para exibir os formulários está presente.
#    Também verifica a presença do título "Formulários Criados" e das seções
#    de cabeçalho (`thead`) e corpo (`tbody`) da tabela.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('devo ver uma tabela com os formulários criados') do
  expect(page).to have_selector('table')
  expect(page).to have_content('Formulários Criados')
  expect(page).to have_selector('thead') # Cabeçalho da tabela
  expect(page).to have_selector('tbody') # Corpo da tabela
end

##
# Então: Para cada formulário devo ver o nome, a data de criação e o status (ativo/inativo).
#
# Descrição: Verifica se as colunas esperadas (Nome, Data de Criação, Status)
#    estão presentes na tabela. Assegura que há pelo menos um formulário exibido
#    e que o status "Ativo" está visível, indicando que os dados estão sendo
#    carregados corretamente.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('para cada formulário devo ver o nome, a data de criação e o status \\(ativo\\/inativo)') do
  # Verifica se a tabela tem as colunas corretas
  expect(page).to have_content('Nome')
  expect(page).to have_content('Data de Criação')
  expect(page).to have_content('Status')

  # Verifica se há pelo menos um formulário sendo exibido
  expect(page).to have_selector('tbody tr', minimum: 1)

  # Verifica se existe status "Ativo"
  expect(page).to have_content('Ativo')
end

##
# Então: Deve haver um botão disponível para cada formulário.
#
# Descrição: Verifica que o número de botões com o texto especificado na página
#    corresponde ao número total de formulários criados, garantindo que cada
#    formulário tenha sua ação correspondente.
# Argumentos:
#    - `botao_texto` (String): O texto visível do botão esperado (e.g., "Visualizar Resultados").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('deve haver um botão {string} disponível para cada formulário') do |botao_texto|
  formularios_count = Formulario.count
  expect(formularios_count).to be > 0

  # Verifica se há o mesmo número de botões que formulários
  expect(page).to have_button(botao_texto, count: formularios_count)
end

##
# Então: Devo ver uma mensagem de formulários.
#
# Descrição: Verifica a presença de uma mensagem específica na página,
#    geralmente indicando a ausência de formulários ou um status geral.
# Argumentos:
#    - `mensagem` (String): O texto da mensagem esperada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('devo ver uma mensagem de formulários como {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

##
# Então: Não deve haver nenhuma tabela ou botão exibido.
#
# Descrição: Verifica que não há uma tabela HTML nem botões com o texto
#    especificado na página, confirmando que nenhum formulário está sendo
#    exibido (e.g., quando não há formulários criados).
# Argumentos:
#    - `botao_texto` (String): O texto visível de um botão que não deve estar presente.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('não deve haver nenhuma tabela ou botão {string} exibido') do |botao_texto|
  expect(page).not_to have_selector('table')
  expect(page).not_to have_button(botao_texto)
end
