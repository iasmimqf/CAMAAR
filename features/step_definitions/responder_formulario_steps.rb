# features/step_definitions/responder_formulario_steps.rb

# --- DADO ---

Dado('que estou autenticado como aluno') do
  @aluno = create(:usuario, email: "aluno@test.com", password: 'password123', admin: false)
  
  # Fazer login manual via Capybara
  visit '/usuarios/sign_in'
  fill_in 'usuario[login]', with: @aluno.email
  fill_in 'usuario[password]', with: 'password123'
  click_button 'Entrar'
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
  admin = create(:usuario, :admin, email: "admin_resp@test.com")
  
  # Cria template e questões
  @template = create(:template, titulo: 'Avaliação de Disciplina', criador: admin)
  
  # Cria formulário
  @formulario = Formulario.new(template: @template, criador: admin)
  @formulario.turmas = [@turma]
  @formulario.save!
end

Dado('o formulário contém {int} questões de múltipla escolha \\(escala 1-5)') do |quantidade|
  quantidade.times do |i|
    create(:questao, 
      template: @template, 
      enunciado: "Questão de escala #{i+1}: Como você avalia este aspecto?", 
      tipo: 'Escala',
      obrigatoria: true
    )
  end
end

Dado('o formulário contém {int} questões abertas') do |quantidade|
  quantidade.times do |i|
    create(:questao, 
      template: @template, 
      enunciado: "Questão aberta #{i+1}: Deixe seus comentários", 
      tipo: 'Texto',
      obrigatoria: false
    )
  end
end

Dado('existe um formulário disponível para minha turma') do
  # Cria disciplina e turma
  @disciplina = create(:disciplina, nome: 'Engenharia de Software')
  @turma = create(:turma, codigo_turma: '001', disciplina: @disciplina)
  
  # Associa aluno à turma
  @aluno.turmas << @turma
  
  # Cria admin para ser criador
  admin = create(:usuario, :admin, email: "admin_resp2@test.com")
  
  # Cria template com questões obrigatórias e opcionais
  @template = create(:template, titulo: 'Avaliação Geral', criador: admin)
  @questao_obrigatoria = create(:questao, 
    template: @template, 
    enunciado: "Questão obrigatória", 
    tipo: 'Escala',
    obrigatoria: true
  )
  @questao_opcional = create(:questao, 
    template: @template, 
    enunciado: "Questão opcional", 
    tipo: 'Texto',
    obrigatoria: false
  )
  
  # Cria formulário
  @formulario = Formulario.new(template: @template, criador: admin)
  @formulario.turmas = [@turma]
  @formulario.save!
end

Dado('estou respondendo o formulário') do
  visit formulario_path(@formulario)
end

Dado('deixei uma questão obrigatória em branco') do
  # Preenche apenas a questão opcional, deixa a obrigatória em branco
  fill_in "resposta_formulario[respostas_questoes_attributes][1][texto_resposta]", with: "Resposta da questão opcional"
  # Não preenche a questão obrigatória (radio button)
end

# --- QUANDO ---

Quando('acesso a página {string}') do |pagina|
  case pagina
  when 'Formulários Pendentes'
    visit formularios_path
  else
    raise "Página '#{pagina}' não está mapeada nos step definitions"
  end
end

Quando('seleciono o formulário da turma {string}') do |nome_turma|
  # Clica no link "Responder" do formulário
  click_link 'Responder'
end

Quando('preencho todas as questões obrigatórias') do
  # Preenche questões de escala (obrigatórias)
  # Busca todos os grupos de radio buttons únicos
  radio_groups = page.all('input[type="radio"]').map { |r| r[:name] }.uniq
  
  radio_groups.each do |group_name|
    # Para cada grupo, seleciona o valor 4 usando choose diretamente
    radio_4 = page.all("input[name='#{group_name}'][value='4']").first
    if radio_4
      radio_4.choose
    end
  end
  
  # Preenche questões de texto (opcionais)
  textareas = page.all('textarea')
  textareas.each_with_index do |textarea, index|
    fill_in textarea[:name], with: "Comentário #{index + 1}: O professor explica bem os conceitos"
  end
end

# --- ENTÃO ---

Então('o sistema deve exibir {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o formulário deve ser marcado como {string} no meu perfil') do |status|
  # Verifica se a resposta foi criada no banco
  expect(RespostaFormulario.exists?(formulario: @formulario, respondente: @aluno)).to be true
end

Então('as respostas devem ser armazenadas anonimamente no sistema') do
  # Verifica se as respostas foram salvas
  resposta = RespostaFormulario.find_by(formulario: @formulario, respondente: @aluno)
  expect(resposta).to be_present
  expect(resposta.respostas_questoes.count).to be > 0
end

Então('deve manter minhas outras respostas preenchidas') do
  # Verifica se os campos preenchidos mantêm os valores
  expect(page).to have_field("resposta_formulario[respostas_questoes_attributes][1][texto_resposta]", with: "Resposta da questão opcional")
end
