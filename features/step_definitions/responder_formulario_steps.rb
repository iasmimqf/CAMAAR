# Caminho: features/step_definitions/responder_formulario_steps.rb

# --- DADO ---

##
# Dado: Que estou autenticado como aluno.
#
# Descrição: Cria um usuário com o papel de aluno e simula o processo de login
#    via interface web (Capybara) para autenticar o aluno no sistema.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Usuario` no banco de dados.
#    - Realiza uma navegação e interação com o formulário de login.
#    - Define a variável de instância `@aluno`.
Dado('que estou autenticado como aluno') do
  @aluno = create(:usuario, email: "aluno@test.com", password: 'password123', admin: false)

  # Fazer login manual via Capybara
  visit '/usuarios/sign_in'
  fill_in 'usuario[login]', with: @aluno.email
  fill_in 'usuario[password]', with: 'password123'
  click_button 'Entrar'
end

##
# Dado: Existe um formulário disponível para a turma.
#
# Descrição: Cria uma disciplina, uma turma associada e um template de formulário.
#    Associa o aluno à turma e cria um formulário baseado no template, vinculando-o à turma.
# Argumentos:
#    - `nome_turma` (String): O nome completo da turma (e.g., "Nome da Disciplina - Código da Turma").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria registros de `Disciplina`, `Turma`, `Usuario` (admin), `Template` e `Formulario` no banco de dados.
#    - Associa o aluno à turma.
#    - Define as variáveis de instância `@disciplina`, `@turma`, `@template` e `@formulario`.
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
  @formulario.turmas = [ @turma ]
  @formulario.save!
end

##
# Dado: O formulário contém questões de múltipla escolha (escala 1-5).
#
# Descrição: Adiciona um número especificado de questões do tipo 'Escala'
#    (com escala de 1 a 5) ao template do formulário atualmente em uso.
# Argumentos:
#    - `quantidade` (Integer): O número de questões de escala a serem adicionadas.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Cria registros de `Questao` no banco de dados, associados ao `@template`.
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

##
# Dado: O formulário contém questões abertas.
#
# Descrição: Adiciona um número especificado de questões do tipo 'Texto'
#    (questões abertas) ao template do formulário atualmente em uso.
# Argumentos:
#    - `quantidade` (Integer): O número de questões abertas a serem adicionadas.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Cria registros de `Questao` no banco de dados, associados ao `@template`.
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

##
# Dado: Existe um formulário disponível para minha turma.
#
# Descrição: Cria uma disciplina e uma turma, associa o aluno a essa turma.
#    Em seguida, cria um template com questões obrigatórias e opcionais,
#    e um formulário vinculado a esse template e turma.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria registros de `Disciplina`, `Turma`, `Usuario` (admin), `Template`, `Questao` e `Formulario` no banco de dados.
#    - Associa o aluno à turma.
#    - Define as variáveis de instância `@disciplina`, `@turma`, `@template`, `@questao_obrigatoria`, `@questao_opcional` e `@formulario`.
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
  @formulario.turmas = [ @turma ]
  @formulario.save!
end

##
# Dado: Estou respondendo o formulário.
#
# Descrição: Simula a navegação do usuário para a página de resposta de um formulário específico.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Altera a página atual do navegador simulado para a página do formulário.
Dado('estou respondendo o formulário') do
  visit formulario_path(@formulario)
end

##
# Dado: Deixei uma questão obrigatória em branco.
#
# Descrição: Simula o preenchimento de apenas uma questão opcional no formulário,
#    deixando uma questão obrigatória em branco para testar a validação.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Preenche um campo de texto na página.
Dado('deixei uma questão obrigatória em branco') do
  # Preenche apenas a questão opcional, deixa a obrigatória em branco
  fill_in "resposta_formulario[respostas_questoes_attributes][1][texto_resposta]", with: "Resposta da questão opcional"
  # Não preenche a questão obrigatória (radio button)
end

# --- QUANDO ---

##
# Quando: Acesso a uma página específica.
#
# Descrição: Navega para a página especificada pelo nome. Este passo atua como
#    um roteador para diferentes páginas da aplicação no contexto dos testes.
# Argumentos:
#    - `pagina` (String): O nome da página para a qual navegar (e.g., 'Formulários Pendentes').
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Altera a página atual do navegador simulado.
#    - Pode levantar uma exceção se o nome da página for desconhecido.
Quando('acesso a página {string}') do |pagina|
  case pagina
  when 'Formulários Pendentes'
    visit formularios_path
  else
    raise "Página '#{pagina}' não está mapeada nos step definitions"
  end
end

##
# Quando: Seleciono o formulário da turma.
#
# Descrição: Simula o clique no link "Responder" associado a um formulário
#    de uma turma específica, levando o usuário para a página de resposta.
# Argumentos:
#    - `nome_turma` (String): O nome da turma do formulário a ser selecionado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Altera a página atual do navegador simulado.
Quando('seleciono o formulário da turma {string}') do |nome_turma|
  # Clica no link "Responder" do formulário
  click_link 'Responder'
end

##
# Quando: Preencho todas as questões obrigatórias.
#
# Descrição: Simula o preenchimento de todas as questões obrigatórias
#    do formulário. Para questões de escala, seleciona um valor (4).
#    Para questões de texto, preenche com um comentário genérico.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Interage com os campos do formulário na página, preenchendo-os.
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

##
# Então: O sistema deve exibir uma mensagem.
#
# Descrição: Verifica se uma mensagem específica é exibida na página,
#    confirmando o resultado de uma operação.
# Argumentos:
#    - `mensagem` (String): O texto da mensagem esperada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('o sistema deve exibir {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

##
# Então: O formulário deve ser marcado como respondido no meu perfil.
#
# Descrição: Verifica se um registro de `RespostaFormulario` foi criado
#    no banco de dados, associando o formulário e o aluno, indicando que
#    o formulário foi respondido.
# Argumentos:
#    - `status` (String): O status esperado (e.g., "respondido").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('o formulário deve ser marcado como {string} no meu perfil') do |status|
  # Verifica se a resposta foi criada no banco
  expect(RespostaFormulario.exists?(formulario: @formulario, respondente: @aluno)).to be true
end

##
# Então: As respostas devem ser armazenadas anonimamente no sistema.
#
# Descrição: Verifica se um registro de `RespostaFormulario` e suas
#    `RespostaQuestoes` associadas foram salvas no banco de dados,
#    confirmando o armazenamento das respostas.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('as respostas devem ser armazenadas anonimamente no sistema') do
  # Verifica se as respostas foram salvas
  resposta = RespostaFormulario.find_by(formulario: @formulario, respondente: @aluno)
  expect(resposta).to be_present
  expect(resposta.respostas_questoes.count).to be > 0
end

##
# Então: Deve manter minhas outras respostas preenchidas.
#
# Descrição: Verifica se um campo de input específico na página mantém
#    o valor que foi preenchido anteriormente, garantindo que os dados
#    não foram perdidos (e.g., após uma validação que falhou).
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('deve manter minhas outras respostas preenchidas') do
  # Verifica se os campos preenchidos mantêm os valores
  expect(page).to have_field("resposta_formulario[respostas_questoes_attributes][1][texto_resposta]", with: "Resposta da questão opcional")
end
