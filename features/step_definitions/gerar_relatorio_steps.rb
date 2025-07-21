# features/step_definitions/gerar_relatorio_steps.rb

Dado('que estou autenticado como administrador para relatórios') do
  @admin_usuario = Usuario.find_or_create_by(email: 'admin@test.com') do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.admin = true
    user.matricula = 'admin123'
    user.nome = 'Administrador'
  end

  visit '/usuarios/sign_in'
  fill_in 'usuario[login]', with: @admin_usuario.email
  fill_in 'usuario[password]', with: 'password123'
  click_button 'Entrar'
end

Dado('existem turmas com formulários enviados') do
  # Criar disciplinas
  @disciplina_bd = Disciplina.find_or_create_by(nome: 'Banco de Dados', codigo: 'CIC123')
  @disciplina_eng = Disciplina.find_or_create_by(nome: 'Engenharia de Software', codigo: 'CIC456')
  @disciplina_algebra = Disciplina.find_or_create_by(nome: 'Álgebra 1', codigo: 'MAT101')

  # Criar turmas
  @turma01_bd = Turma.find_or_create_by(codigo_turma: 'Turma 01', disciplina: @disciplina_bd, semestre: '2025.1')
  @turma02_bd = Turma.find_or_create_by(codigo_turma: 'Turma 02', disciplina: @disciplina_bd, semestre: '2025.1')
  @turma01_eng = Turma.find_or_create_by(codigo_turma: 'Turma 01', disciplina: @disciplina_eng, semestre: '2025.1')
  @turma02_algebra = Turma.find_or_create_by(codigo_turma: 'Turma 02', disciplina: @disciplina_algebra, semestre: '2025.1')

  # Criar template
  @template = Template.find_or_create_by(titulo: 'Avaliação Padrão') do |t|
    t.criador = @admin_usuario
  end
  @template.skip_questoes_validation = true
  @template.save!

  # Criar questões para o template
  @questao_professor = @template.questoes.find_or_create_by(
    enunciado: 'Como você avalia o professor?',
    tipo: 'Escala',
    obrigatoria: true,
    opcoes: '5,4,3,2,1'
  )

  @questao_disciplina = @template.questoes.find_or_create_by(
    enunciado: 'Como você avalia a disciplina?',
    tipo: 'Escala',
    obrigatoria: true,
    opcoes: '5,4,3,2,1'
  )

  @questao_comentario = @template.questoes.find_or_create_by(
    enunciado: 'Comentários adicionais',
    tipo: 'Texto',
    obrigatoria: false
  )

  # Criar formulários para as turmas
  @formulario_bd = Formulario.new(
    template: @template,
    criador: @admin_usuario,
    nome: 'Avaliação BD 2025.1',
    prazo_limite: Date.parse('15/08/2025')
  )
  @formulario_bd.turmas = [ @turma01_bd, @turma02_bd ]
  @formulario_bd.save!

  @formulario_eng = Formulario.new(
    template: @template,
    criador: @admin_usuario,
    nome: 'Avaliação ENG 2025.1',
    prazo_limite: Date.parse('20/08/2025')
  )
  @formulario_eng.turmas = [ @turma01_eng ]
  @formulario_eng.save!

  @formulario_algebra = Formulario.new(
    template: @template,
    criador: @admin_usuario,
    nome: 'Avaliação Álgebra 2025.1',
    prazo_limite: Date.parse('20/08/2025')
  )
  @formulario_algebra.turmas = [ @turma02_algebra ]
  @formulario_algebra.save!

  # Criar usuários estudantes
  @estudantes = []
  (1..25).each do |i|
    estudante = Usuario.find_or_create_by(email: "estudante#{i}@test.com") do |user|
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.admin = false
      user.matricula = "estudante#{i}"
      user.nome = "Estudante #{i}"
    end
    @estudantes << estudante
  end

  # Criar respostas para turma 01 BD (15 respostas de 20 possíveis)
  @estudantes[0..14].each_with_index do |estudante, index|
    resposta_form = RespostaFormulario.create!(
      formulario: @formulario_bd,
      respondente: estudante
    )

    # Respostas para questão do professor (média 4.2)
    valor_professor = [ 4, 4, 5, 4, 4, 4, 5, 4, 4, 3, 5, 4, 4, 5, 4 ][index]
    RespostaQuestao.create!(
      resposta_formulario: resposta_form,
      questao: @questao_professor,
      valor_resposta: valor_professor
    )

    # Respostas para questão da disciplina (média 3.8)
    valor_disciplina = [ 4, 3, 4, 4, 3, 4, 4, 3, 4, 3, 5, 3, 4, 4, 3 ][index]
    RespostaQuestao.create!(
      resposta_formulario: resposta_form,
      questao: @questao_disciplina,
      valor_resposta: valor_disciplina
    )

    # Algumas respostas textuais
    if index % 3 == 0
      RespostaQuestao.create!(
        resposta_formulario: resposta_form,
        questao: @questao_comentario,
        texto_resposta: "Comentário do estudante #{index + 1}"
      )
    end
  end

  # Criar respostas para turma 02 BD (18 respostas de 20 possíveis)
  @estudantes[15..17].each_with_index do |estudante, index|
    resposta_form = RespostaFormulario.create!(
      formulario: @formulario_bd,
      respondente: estudante
    )

    # Respostas para questão do professor (média 4.5)
    valor_professor = [ 5, 4, 5 ][index]
    RespostaQuestao.create!(
      resposta_formulario: resposta_form,
      questao: @questao_professor,
      valor_resposta: valor_professor
    )

    # Respostas para questão da disciplina (média 4.1)
    valor_disciplina = [ 4, 4, 4 ][index]
    RespostaQuestao.create!(
      resposta_formulario: resposta_form,
      questao: @questao_disciplina,
      valor_resposta: valor_disciplina
    )
  end
end

Dado('que acesso a página {string}') do |pagina|
  case pagina
  when 'Resultados'
    visit '/admin/formularios/resultados'
  else
    raise "Página #{pagina} não reconhecida"
  end
end

Quando('seleciono a turma {string}') do |turma_nome|
  check_id = case turma_nome
  when 'Turma 01 (Banco de Dados)'
               "turma_#{@turma01_bd.id}"
  when 'Turma 02 (Banco de Dados)'
               "turma_#{@turma02_bd.id}"
  else
               raise "Turma #{turma_nome} não encontrada"
  end
  check(check_id)
end

Quando('clico em {string} para gerar relatório') do |botao|
  click_button botao
end

Então('um arquivo CSV deve ser baixado com nome {string}') do |nome_arquivo|
  # Verificar se o cabeçalho de resposta indica download
  expect(page.response_headers['Content-Type']).to include('text/csv')
  expect(page.response_headers['Content-Disposition']).to include("attachment; filename=\"#{nome_arquivo}\"")
end

Então('o arquivo deve conter:') do |table|
  # Verificar se o CSV contém os dados esperados
  csv_content = page.body

  table.hashes.each do |row|
    expect(csv_content).to include(row['Turma'])
    expect(csv_content).to include(row['Disciplina'])
    expect(csv_content).to include(row['Média Professor'])
    expect(csv_content).to include(row['Média Disciplina'])
    expect(csv_content).to include(row['Respondidos/Enviados'])
  end
end

Então('as respostas textuais devem estar agrupadas por questão') do
  csv_content = page.body
  expect(csv_content).to include('Comentários por questão')
  expect(csv_content).to include('Comentários adicionais')
end

Quando('acesso a página de resultados') do
  visit '/admin/formularios/resultados'
end

Quando('não seleciono nenhuma turma') do
  # Não faz nada - nenhuma turma é selecionada
end

Então('o botão {string} deve estar visível mas desabilitado') do |texto_botao|
  expect(page).to have_button(texto_botao, disabled: true)
end

Dado('que a {string} possui formulário enviado mas nenhuma resposta') do |turma_info|
  # Turma já criada no contexto, apenas garantir que não tem respostas
  if turma_info.include?('Engenharia de Software')
    # Limpar respostas se existirem
    @formulario_eng.resposta_formularios.destroy_all
  end
end

Então('o checkbox ao lado de {string} deve estar desabilitado') do |turma_info|
  if turma_info.include?('Engenharia de Software')
    expect(page).to have_css("input[type='checkbox'][data-turma-id='#{@turma01_eng.id}']:disabled")
  end
end

Quando('tento clicar manualmente no checkbox') do
  # Tenta clicar no checkbox desabilitado
  if @turma01_eng
    expect(page).to have_css("input[type='checkbox'][data-turma-id='#{@turma01_eng.id}']:disabled")
  end
end

Quando('tento clicar manualmente no checkbox') do
  # Tenta clicar no checkbox desabilitado
  if @turma01_eng
    expect(page).to have_css("input[type='checkbox'][data-turma-id='#{@turma01_eng.id}']:disabled")
  end
end

Então('a turma não é adicionada à lista de selecionadas') do
  # Verificar que a turma não foi selecionada
  if @turma01_eng
    checkbox = find("input[type='checkbox'][data-turma-id='#{@turma01_eng.id}']")
    expect(checkbox).not_to be_checked
  end
end
