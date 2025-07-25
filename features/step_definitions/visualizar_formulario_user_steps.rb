# Caminho: features/step_definitions/visualizar_formulario_user_steps.rb
# encoding: utf-8

##
# Dado: Que estou logado como usuário.
#
# Descrição: Cria um usuário comum (não administrador) no sistema e simula
#    o processo de login via interface web (Capybara) para autenticá-lo.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Usuario` no banco de dados.
#    - Realiza uma navegação e interação com o formulário de login.
#    - Define a variável de instância `@usuario`.
#    - Verifica a presença de uma mensagem de sucesso de login na página.
Dado('que estou logado como usuário') do
  # Cria um usuário comum (não admin)
  @usuario = Usuario.create!(
    email: 'usuario@teste.com',
    password: 'password123',
    password_confirmation: 'password123',
    admin: false
  )

  # Simula login manual via Capybara
  visit '/usuarios/sign_in'
  fill_in 'usuario[login]', with: @usuario.email
  fill_in 'usuario[password]', with: 'password123'
  click_button 'Entrar'

  expect(page).to have_content('Login efetuado com sucesso')
end

##
# Dado: Existem formulários não respondidos para minhas turmas.
#
# Descrição: Cria disciplinas, turmas e um template básico. Associa o usuário
#    logado às turmas e, em seguida, cria formulários vinculados a essas turmas
#    e ao template, simulando formulários pendentes para o usuário responder.
# Argumentos:
#    - `table` (Cucumber::MultilineArgument::DataTable): Uma tabela contendo
#      os detalhes dos formulários, incluindo 'Disciplina', 'Turma', 'Nome' e 'Prazo'.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria registros de `Disciplina`, `Turma`, `Template`, `Questao` e `Formulario` no banco de dados.
#    - Associa o `@usuario` às turmas criadas.
#    - Define a variável de instância `@template`.
Dado('existem formulários não respondidos para minhas turmas:') do |table|
  # Primeiro, cria as disciplinas
  disciplinas = {}
  table.hashes.each do |row|
    disciplina_nome = row['Disciplina']
    unless disciplinas[disciplina_nome]
      disciplinas[disciplina_nome] = Disciplina.create!(
        nome: disciplina_nome,
        codigo: disciplina_nome.gsub(/\s+/, '').upcase
      )
    end
  end

  # Cria as turmas e associa o usuário
  turmas = {}
  table.hashes.each do |row|
    turma_nome = row['Turma']
    disciplina_nome = row['Disciplina']

    unless turmas[turma_nome]
      turmas[turma_nome] = Turma.create!(
        codigo_turma: turma_nome,
        disciplina: disciplinas[disciplina_nome],
        semestre: '2024.1'
      )

      # Associa o usuário à turma
      @usuario.turmas << turmas[turma_nome]
    end
  end

  # Cria um template básico
  @template = Template.new(
    titulo: 'Template Teste',
    criador: @usuario
  )
  # Nota: `skip_questoes_validation` não é um método padrão do Rails/ActiveRecord.
  # Se for um método customizado, certifique-se de que ele está definido no modelo Template.
  @template.skip_questoes_validation = true
  @template.save!

  # Adiciona uma questão ao template
  @template.questoes.create!(
    enunciado: 'Como você avalia?',
    tipo: 'Escala',
    opcoes: '5,4,3,2,1',
    obrigatoria: true
  )

  # Cria os formulários
  table.hashes.each do |row|
    formulario = Formulario.new(
      # Nota: O campo 'nome' em Formulario não é padrão. Se não existir, use 'titulo' ou remova.
      nome: row['Nome'], # Assumindo que 'nome' é um atributo válido em Formulario
      template: @template,
      criador: @usuario,
      prazo: Date.parse(row['Prazo']) # Correção: usar 'prazo' em vez de 'prazo_limite'
    )

    # Associa o formulário à turma correspondente
    turma_nome = row['Turma']
    formulario.turmas = [ turmas[turma_nome] ]
    formulario.save!
  end
end

##
# Dado: Não existem formulários não respondidos para minhas turmas.
#
# Descrição: Cria uma disciplina e uma turma, associa o usuário a essa turma,
#    mas não cria nenhum formulário para ela, simulando um cenário onde não
#    há formulários pendentes para o usuário.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria registros de `Disciplina` e `Turma` no banco de dados.
#    - Associa o `@usuario` à turma criada.
Dado('não existem formulários não respondidos para minhas turmas') do
  # Cria uma disciplina e turma para o usuário
  disciplina = Disciplina.create!(
    nome: 'Disciplina Teste',
    codigo: 'DISC001'
  )

  turma = Turma.create!(
    codigo_turma: 'Turma Test',
    disciplina: disciplina,
    semestre: '2024.1'
  )

  # Associa o usuário à turma mas não cria formulários
  @usuario.turmas << turma
end

##
# Quando: Acesso uma página específica.
#
# Descrição: Navega para a página especificada pelo nome.
# Argumentos:
#    - `pagina` (String): O nome da página para a qual navegar (e.g., 'Meus Formulários').
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Altera a página atual do navegador simulado.
#    - Pode levantar uma exceção se o nome da página for desconhecido.
Quando('acesso {string}') do |pagina|
  case pagina
  when 'Meus Formulários'
    visit formularios_path
  else
    raise "Página '#{pagina}' não reconhecida"
  end
end

##
# Então: Devo ver uma lista contendo.
#
# Descrição: Verifica se a página exibe os cabeçalhos esperados para a lista
#    de formulários e se o botão "Responder" está presente, indicando que
#    os formulários estão sendo listados corretamente.
# Argumentos:
#    - `string` (String): Um argumento genérico (não utilizado diretamente, mas indica a presença de uma lista).
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('devo ver uma lista contendo:') do |string|
  # Verifica se os elementos estão presentes na página
  expect(page).to have_content('Nome do formulário')
  expect(page).to have_content('Matéria associada')
  expect(page).to have_content('Turma associada')
  expect(page).to have_content('Data limite para resposta')
  expect(page).to have_link('Responder')
end

##
# Então: Devo ver a mensagem de formulários pendentes.
#
# Descrição: Verifica a presença de uma mensagem específica na página,
#    geralmente indicando a ausência de formulários pendentes.
# Argumentos:
#    - `mensagem` (String): O texto da mensagem esperada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('devo ver a mensagem de formulários pendentes {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

##
# Então: A lista deve estar vazia.
#
# Descrição: Verifica que nenhum botão "Responder" está presente e que
#    o corpo de uma tabela (se aplicável) não contém linhas, confirmando
#    que a lista de formulários está vazia.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('a lista deve estar vazia') do
  # Verifica se não há formulários listados
  expect(page).not_to have_button('Responder')
  expect(page).not_to have_css('table tbody tr') # Assumindo que usa uma tabela
end
