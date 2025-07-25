# encoding: utf-8

Dado('que estou logado como usuário') do
  # Cria um usuário comum (não admin)
  @usuario = Usuario.create!(
    email: 'usuario@teste.com',
    password: 'Password123!',
    password_confirmation: 'Password123!',
    admin: false
  )

  # Login usando a abordagem programática (como nos outros step definitions)
  login_as(@usuario, scope: :usuario)
end

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
      nome: row['Nome'],
      template: @template,
      criador: @usuario,
      prazo_limite: Date.parse(row['Prazo'])
    )

    # Associa o formulário à turma correspondente
    turma_nome = row['Turma']
    formulario.turmas = [ turmas[turma_nome] ]
    formulario.save!
  end
end

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

Quando('acesso {string}') do |pagina|
  case pagina
  when 'Meus Formulários'
    visit formularios_path
  else
    raise "Página '#{pagina}' não reconhecida"
  end
end

Então('devo ver uma lista contendo:') do |string|
  # Verifica se os elementos estão presentes na página
  expect(page).to have_content('Nome do formulário')
  expect(page).to have_content('Matéria associada')
  expect(page).to have_content('Turma associada')
  expect(page).to have_content('Data limite para resposta')
  expect(page).to have_link('Responder')
end

Então('devo ver a mensagem de formulários pendentes {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('a lista deve estar vazia') do
  # Verifica se não há formulários listados
  expect(page).not_to have_button('Responder')
  expect(page).not_to have_css('table tbody tr') # Assumindo que usa uma tabela
end
