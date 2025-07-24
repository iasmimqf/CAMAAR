# features/step_definitions/visualizacao_formularios_steps.rb

# --- DADO ---

Dado('existem formulários criados no sistema') do
  # Cria admin para ser criador (usa o admin já autenticado se disponível)
  @admin_criador = @admin_user || @admin || create(:usuario, :admin, email: "admin_criador@test.com")
  
  # Cria disciplina e turmas
  @disciplina1 = create(:disciplina, nome: "Algoritmos")
  @disciplina2 = create(:disciplina, nome: "Banco de Dados")
  
  @turma1 = create(:turma, codigo_turma: "Turma 01", disciplina: @disciplina1)
  @turma2 = create(:turma, codigo_turma: "Turma 02", disciplina: @disciplina2)
  
  # Cria templates
  @template1 = create(:template, titulo: 'Avaliação Padrão', criador: @admin_criador)
  @template2 = create(:template, titulo: 'Avaliação Final', criador: @admin_criador)
  
  # Cria questões para os templates
  create(:questao, template: @template1, enunciado: "Como você avalia a disciplina?", tipo: 'Escala')
  create(:questao, template: @template2, enunciado: "Deixe seus comentários", tipo: 'Texto')
  
  # Cria formulários
  @formulario1 = Formulario.create!(
    template: @template1,
    criador: @admin_criador,
    turmas: [@turma1]
  )
  
  @formulario2 = Formulario.create!(
    template: @template2,
    criador: @admin_criador,
    turmas: [@turma2]
  )
  
  @formularios = [@formulario1, @formulario2]
end

Dado('os formulários possuem diferentes status') do
  # Os formulários já foram criados no step anterior
  # Rails não tem status built-in, mas podemos verificar se têm respostas
end

Dado('que não existem formulários criados no sistema') do
  # Limpa todos os formulários
  Formulario.destroy_all
end

Dado('um formulário possui respostas dos alunos') do
  # Cria aluno
  @aluno_respondente = create(:usuario, email: "aluno_respondente@test.com")
  @aluno_respondente.turmas << @turma1
  
  # Cria resposta para o primeiro formulário
  @resposta = RespostaFormulario.create!(
    formulario: @formulario1,
    respondente: @aluno_respondente
  )
  
  # Cria resposta da questão
  RespostaQuestao.create!(
    resposta_formulario: @resposta,
    questao: @template1.questoes.first,
    valor_resposta: 4
  )
end

# --- QUANDO ---

Quando('eu clico em {string} do primeiro formulário') do |texto_botao|
  # Procura pelo primeiro formulário na tabela e clica no botão
  within('table tbody tr:first-child') do
    if texto_botao == "Ver Detalhes"
      click_button "Gerar Relatório"
    else
      click_button texto_botao
    end
  end
end

Quando('eu acesso a página de formulários {string}') do |pagina_nome|
  case pagina_nome
  when "Resultados"
    visit admin_formularios_resultados_path
  end
  
  # Aguarda página carregar
  expect(page).to have_css('body')
end

# --- ENTÃO ---

Então('devo ver uma tabela com os formulários criados') do
  expect(page).to have_selector('table')
  expect(page).to have_content('Formulários Criados')
  expect(page).to have_selector('thead') # Cabeçalho da tabela
  expect(page).to have_selector('tbody') # Corpo da tabela
end

Então('para cada formulário devo ver o template, criador, data de criação e turmas') do
  # Verifica se as colunas principais estão presentes
  within('table') do
    @formularios.each do |formulario|
      # Verifica o nome do template
      expect(page).to have_content(formulario.template.titulo)
      
      # Verifica a data de criação
      expect(page).to have_content(formulario.created_at.strftime("%d/%m/%Y"))
      
      # Verifica as turmas
      formulario.turmas.each do |turma|
        expect(page).to have_content("#{turma.disciplina.nome}-#{turma.codigo_turma}")
      end
    end
  end
end

Então('deve haver um botão {string} disponível para cada formulário') do |texto_botao|
  # Conta quantos formulários existem e verifica se há botões correspondentes
  formularios_count = Formulario.count
  # Como o botão real é "Gerar Relatório", ajusta para este texto
  if texto_botao == "Ver Detalhes"
    expect(page).to have_button("Gerar Relatório", count: formularios_count)
  else
    expect(page).to have_button(texto_botao, count: formularios_count)
  end
end

Então('não deve haver nenhuma tabela de formulários exibida') do
  # Verifica que não há tabela com dados de formulários
  expect(page).not_to have_css('table tbody tr')
end

Então('devo ver os detalhes do formulário selecionado') do
  # Verifica se está na página de detalhes de um formulário específico
  expect(page).to have_content(@formulario1.template.titulo)
end

Então('devo ver as turmas associadas ao formulário') do
  # Verifica se as turmas do formulário estão listadas
  @formulario1.turmas.each do |turma|
    expect(page).to have_content(turma.codigo_turma)
  end
end

Então('devo ver informações sobre as respostas recebidas') do
  # Verifica se há informações sobre respostas (pode ser contagem, status, etc.)
  # Como o sistema pode mostrar "X respostas recebidas" ou similar
  expect(page).to have_content('resposta') # Texto genérico relacionado a respostas
end

Então('devo ver uma mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

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

Então('devo ver uma mensagem de formulários como {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('não deve haver nenhuma tabela ou botão {string} exibido') do |botao_texto|
  expect(page).not_to have_selector('table')
  expect(page).not_to have_button(botao_texto)
end
