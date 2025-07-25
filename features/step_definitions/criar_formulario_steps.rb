# Caminho: features/step_definitions/criar_formulario_steps.rb

# --- DADO (Setup dos Cenários) ---

# --- BEFORE/AFTER HOOKS ---
##
# Hook Before: Realiza a limpeza do banco de dados antes de cada cenário.
#
# Descrição: Este hook é executado antes de cada cenário de teste. Ele garante
#    que os dados de `Formulario` sejam removidos e que a fila de e-mails do
#    Action Mailer seja limpa, assegurando um estado inicial consistente para os testes.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Exclui todos os registros da tabela `formularios`.
#    - Limpa a fila de e-mails (`ActionMailer::Base.deliveries`).
Before do
  # Limpeza mais seletiva para evitar problemas de foreign key
  Formulario.destroy_all
  ActionMailer::Base.deliveries.clear
end

# --- DADO ---
# Reutiliza o step de autenticação do template_steps.rb

##
# Dado: Existem templates de formulário cadastrados.
#
# Descrição: Cria templates de formulário (`Avaliação Padrão` e `Avaliação Detalhada`)
#    e questões associadas, utilizando FactoryBot. Associa os templates a um criador
#    (administrador) que deve estar previamente definido no contexto do teste.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria registros de `Template` e `Questao` no banco de dados.
#    - Define as variáveis de instância `@template_avaliacao` e `@template_outro`.
Dado('existem templates de formulário cadastrados') do
  # Usa @admin ou @admin_user dependendo de qual está definido
  criador = @admin || @admin_user
  @template_avaliacao = create(:template, titulo: 'Avaliação Padrão', criador: criador)
  create(:questao, template: @template_avaliacao, enunciado: 'Como você avalia a disciplina?', tipo: 'Escala')

  @template_outro = create(:template, titulo: 'Avaliação Detalhada', criador: criador)
  create(:questao, template: @template_outro, enunciado: 'Comentários sobre a disciplina', tipo: 'Texto')
end

##
# Dado: Existem turmas ativas para o semestre atual.
#
# Descrição: Cria registros de `Disciplina` e `Turma` no banco de dados,
#    simulando turmas ativas para o semestre corrente.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria registros de `Disciplina` e `Turma` no banco de dados.
#    - Define as variáveis de instância `@disciplina1`, `@disciplina2`,
#      `@turma01`, `@turma02`, `@turma03`, `@turma04`.
Dado('existem turmas ativas para o semestre atual') do
  @disciplina1 = create(:disciplina, nome: 'Banco de Dados')
  @disciplina2 = create(:disciplina, nome: 'Engenharia de Software')

  @turma01 = create(:turma, codigo_turma: 'Turma 01', disciplina: @disciplina1, semestre: '2025.1')
  @turma02 = create(:turma, codigo_turma: 'Turma 02', disciplina: @disciplina1, semestre: '2025.1')
  @turma03 = create(:turma, codigo_turma: 'Turma 03', disciplina: @disciplina2, semestre: '2025.1')
  @turma04 = create(:turma, codigo_turma: 'Turma 04', disciplina: @disciplina2, semestre: '2025.1')
end

##
# Dado: A turma já foi avaliada neste semestre.
#
# Descrição: Simula que uma turma específica já possui um formulário de avaliação
#    associado, criando um `Formulario` e associando-o à turma. A validação do
#    formulário é ignorada para garantir a criação do cenário.
# Argumentos:
#    - `codigo_turma` (String): O código da turma que já foi avaliada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Formulario` no banco de dados.
#    - Associa o formulário à turma especificada.
Dado('a turma {string} já foi avaliada neste semestre') do |codigo_turma|
  turma = Turma.find_by(codigo_turma: codigo_turma)
  criador = @admin || @admin_user
  formulario_existente = build(:formulario, template: @template_avaliacao, criador: criador)
  formulario_existente.save(validate: false) # Pula validação para criar o formulário
  formulario_existente.turmas << turma
end

##
# Dado: Não existem templates de formulário cadastrados.
#
# Descrição: Remove todos os registros de `Template` do banco de dados,
#    garantindo que nenhum template esteja presente para o cenário de teste.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Exclui todos os registros da tabela `templates`.
Dado('não existem templates de formulário cadastrados') do
  Template.destroy_all
end

##
# Dado: Não existem turmas ativas para o semestre atual.
#
# Descrição: Remove todos os registros de `Turma` do banco de dados,
#    garantindo que nenhuma turma esteja presente para o cenário de teste.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Exclui todos os registros da tabela `turmas`.
Dado('não existem turmas ativas para o semestre atual') do
  Turma.destroy_all
end

# --- QUANDO ---
##
# Quando: Eu acesso a página de criação de formulário.
#
# Descrição: Simula a navegação do usuário para a página de criação de formulários
#    administrativos.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Altera a página atual do navegador simulado.
Quando('eu acesso a página de criação de formulário') do
  visit new_admin_formulario_path
end

##
# Quando: Eu seleciono o template.
#
# Descrição: Simula a seleção de um template específico em um campo de seleção
#    (dropdown) no formulário de criação de formulário, usando o nome do template.
# Argumentos:
#    - `template_nome` (String): O título do template a ser selecionado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Interage com o formulário na página.
Quando('eu seleciono o template {string}') do |template_nome|
  select template_nome, from: 'formulario[template_id]'
end

##
# Quando: Eu seleciono múltiplas turmas.
#
# Descrição: Simula a seleção de múltiplas turmas em campos de checkbox
#    no formulário de criação de formulário, usando os nomes das turmas.
# Argumentos:
#    - `turma1` (String): O código da primeira turma a ser selecionada.
#    - `turma2` (String): O código da segunda turma a ser selecionada.
#    - `turma3` (String): O código da terceira turma a ser selecionada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Interage com o formulário na página.
Quando('eu seleciono as turmas {string}, {string} e {string}') do |turma1, turma2, turma3|
  [ turma1, turma2, turma3 ].each do |turma_nome|
    turma = Turma.find_by(codigo_turma: turma_nome)
    check "turma_#{turma.id}" if turma
  end
end

##
# Quando: Eu seleciono uma única turma.
#
# Descrição: Simula a seleção de uma turma específica em um campo de checkbox
#    no formulário de criação de formulário, usando o nome da turma.
# Argumentos:
#    - `turma_nome` (String): O código da turma a ser selecionada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Interage com o formulário na página.
Quando('eu seleciono a turma {string}') do |turma_nome|
  turma = Turma.find_by(codigo_turma: turma_nome)
  check "turma_#{turma.id}" if turma
end

##
# Quando: Eu não seleciono nenhuma turma.
#
# Descrição: Este passo não realiza nenhuma ação, simulando o cenário em que
#    nenhuma turma é marcada no formulário de criação de formulário.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
Quando('eu não seleciono nenhuma turma') do
  # Não faz nada - deixa todas as turmas desmarcadas
end

##
# Quando: Eu clico em um botão.
#
# Descrição: Simula o clique em um botão na página, identificado pelo seu texto.
# Argumentos:
#    - `botao_texto` (String): O texto visível do botão a ser clicado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Dispara a ação associada ao botão clicado.
Quando('eu clico em {string}') do |botao_texto|
  click_button botao_texto
end

# --- ENTÃO ---
##
# Então: Devo ver mensagem de sucesso de formulário.
#
# Descrição: Verifica se uma mensagem de sucesso específica é exibida na página,
#    confirmando que a operação de formulário foi bem-sucedida.
# Argumentos:
#    - `mensagem` (String): O texto da mensagem de sucesso esperada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('devo ver mensagem de sucesso de formulário {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

##
# Então: Devo ver mensagem de erro de formulário.
#
# Descrição: Verifica se uma mensagem de erro específica é exibida na página,
#    indicando que a operação de formulário falhou.
# Argumentos:
#    - `mensagem_erro` (String): O texto da mensagem de erro esperada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('devo ver mensagem de erro de formulário {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

##
# Então: Eu devo ver a mensagem.
#
# Descrição: Uma verificação genérica para a presença de qualquer texto na página.
# Argumentos:
#    - `mensagem` (String): O texto que se espera encontrar na página.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('eu devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

##
# Então: As turmas devem estar associadas ao novo formulário.
#
# Descrição: Verifica se um formulário foi criado e se ele possui turmas
#    associadas, confirmando o sucesso da criação e associação. Também verifica
#    se o usuário foi redirecionado para a página correta após a operação.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('as turmas devem estar associadas ao novo formulário') do
  # Verifica se o formulário foi criado e tem as turmas associadas
  formulario = Formulario.last
  expect(formulario).to be_present
  expect(formulario.turmas.count).to be > 0

  # Verifica se a página atual mostra o sucesso
  expect(current_path).to eq(admin_formularios_path)
end

##
# Então: O botão deve estar desabilitado.
#
# Descrição: Verifica se um botão específico, identificado pelo seu texto,
#    está presente na página e se encontra desabilitado.
# Argumentos:
#    - `botao_texto` (String): O texto visível do botão a ser verificado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('o botão {string} deve estar desabilitado') do |botao_texto|
  # Verifica se o botão existe e está desabilitado
  expect(page).to have_button(botao_texto, disabled: true)
end
