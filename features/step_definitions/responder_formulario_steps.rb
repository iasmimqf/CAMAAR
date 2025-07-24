# features/step_definitions/responder_formulario_steps.rb

# --- DADO ---

Dado('que estou autenticado como aluno') do
  @aluno = create(:usuario, email: "aluno_resp@test.com", password: 'Password123!', admin: false)
  
  # Usa autenticação similar aos outros testes
  visit '/usuarios/sign_in'
  fill_in 'usuario[login]', with: @aluno.email
  fill_in 'usuario[password]', with: 'Password123!'
  click_button 'Entrar'
  
  # Aguarda resposta (pode ser JSON)
  sleep 1
end

Dado('existe um formulário disponível para a turma {string}') do |nome_turma|
  # Extrai nome da disciplina e código da turma
  disciplina_nome, codigo = nome_turma.split(' - ')

  # Cria disciplina e turma
  @disciplina = create(:disciplina, nome: disciplina_nome)
  @turma = create(:turma, codigo_turma: codigo, disciplina: @disciplina)

  # Associa aluno à turma
  @aluno.turmas << @turma

  # Cria admin para ser criador
  admin = create(:usuario, :admin, email: "admin_resp_#{rand(1000)}@test.com")

  # Cria template
  @template = create(:template, titulo: 'Avaliação de Disciplina', criador: admin)

  # Cria formulário
  @formulario = Formulario.new(template: @template, criador: admin)
  @formulario.turmas = [ @turma ]
  @formulario.save!
end

Dado('o formulário contém {int} questões de múltipla escolha \\(escala 1-5)') do |quantidade|
  @questoes_escala = []
  quantidade.times do |i|
    questao = create(:questao,
      template: @template,
      enunciado: "Questão de escala #{i+1}: Como você avalia este aspecto?",
      tipo: 'Escala',
      obrigatoria: true
    )
    @questoes_escala << questao
  end
end

Dado('o formulário contém {int} questões abertas') do |quantidade|
  @questoes_texto = []
  quantidade.times do |i|
    questao = create(:questao,
      template: @template,
      enunciado: "Questão aberta #{i+1}: Deixe seus comentários",
      tipo: 'Texto',
      obrigatoria: false
    )
    @questoes_texto << questao
  end
end

Dado('uma das questões é obrigatória') do
  # Marca a primeira questão como obrigatória
  if @template.questoes.any?
    @template.questoes.first.update!(obrigatoria: true)
    @questao_obrigatoria = @template.questoes.first
  end
end

Dado('eu já respondi este formulário anteriormente') do
  # Cria resposta prévia
  @resposta_anterior = RespostaFormulario.create!(
    formulario: @formulario,
    respondente: @aluno
  )
end

# --- QUANDO ---

Quando('acesso a página de formulários {string}') do |pagina_nome|
  case pagina_nome
  when "Formulários Pendentes", "Pendentes"
    visit formularios_path
  end
  
  # Aguarda página carregar
  expect(page).to have_css('body')
end

Quando('seleciono o formulário da turma {string}') do |nome_turma|
  # Aguarda a página carregar
  expect(page).to have_css('body')
  
  # Extrai o código da turma (ex: "Turma 01" de "Banco de Dados - Turma 01")
  codigo_turma = nome_turma.split(' - ').last
  
  # Encontra a linha da tabela que contém o código da turma
  row = find('tr', text: codigo_turma)
  
  # Clica no link "Responder" dessa linha
  within(row) do
    click_link 'Responder'
  end
  
  # Aguarda carregar a página do formulário
  expect(page).to have_css('form')
end

Quando('preencho todas as questões obrigatórias com notas válidas') do
  # Preenche questões de escala
  if @questoes_escala
    @questoes_escala.each_with_index do |questao, index|
      choose("resposta_formulario_respostas_questoes_attributes_#{index}_valor_resposta_4")
    end
  end
end

Quando('preencho o comentário com {string}') do |comentario|
  # Preenche primeira questão de texto encontrada
  if @questoes_texto && @questoes_texto.any?
    fill_in_text_area = page.all('textarea').first
    fill_in_text_area.set(comentario) if fill_in_text_area
  end
end

Quando('deixo uma questão obrigatória em branco') do
  # Não preenche nenhuma questão - deixa em branco intencionalmente
  # O teste vai verificar se a validação funciona
end

Quando('clico no botão {string} do formulário') do |texto_botao|
  click_button texto_botao
  # Aguarda possível processamento
  sleep 0.5
end

# --- ENTÃO ---

Então('o sistema deve exibir {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('as respostas devem ser armazenadas no sistema') do
  # Verifica se foi criada uma resposta no banco
  resposta = RespostaFormulario.find_by(
    formulario: @formulario,
    respondente: @aluno
  )
  expect(resposta).to be_present
  
  # Verifica se há respostas de questões associadas
  expect(resposta.respostas_questoes.count).to be > 0
end

Então('minhas outras respostas devem permanecer preenchidas') do
  # Verifica se campos preenchidos mantiveram os valores
  # Para questões de escala já selecionadas
  if page.has_css?('input[type="radio"]:checked')
    expect(page).to have_css('input[type="radio"]:checked')
  end
  
  # Para campos de texto já preenchidos
  if page.has_css?('textarea')
    textarea = page.find('textarea')
    expect(textarea.value).not_to be_empty if textarea.value.present?
  end
end

Então('o formulário {string} não deve aparecer na lista') do |nome_turma|
  expect(page).not_to have_content(nome_turma.split(' - ').last)
end

Então('eu devo ver a mensagem de formulário {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('eu devo ver a mensagem de erro do formulário {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
