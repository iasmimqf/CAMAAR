# features/step_definitions/visualizar_formulario_user_steps.rb

# --- DADO ---

Dado('existem formulários não respondidos para minhas turmas') do
  # Cria disciplinas e turmas
  @disciplina1 = create(:disciplina, nome: "Banco de Dados")
  @disciplina2 = create(:disciplina, nome: "Algoritmos")
  
  @turma1 = create(:turma, codigo_turma: "Turma 01", disciplina: @disciplina1)
  @turma2 = create(:turma, codigo_turma: "Turma 02", disciplina: @disciplina2)
  
  # Associa aluno às turmas
  @aluno.turmas << [@turma1, @turma2]
  
  # Cria admin para ser criador
  @admin_criador = create(:usuario, :admin, email: "admin_form_user@test.com")
  
  # Cria templates
  @template1 = create(:template, titulo: 'Avaliação Docente', criador: @admin_criador)
  @template2 = create(:template, titulo: 'Avaliação Infraestrutura', criador: @admin_criador)
  
  # Cria questões
  create(:questao, template: @template1, enunciado: "Como você avalia o professor?", tipo: 'Escala')
  create(:questao, template: @template2, enunciado: "Como você avalia a sala?", tipo: 'Texto')
  
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
  
  @formularios_pendentes = [@formulario1, @formulario2]
end

Dado('os formulários possuem diferentes templates e disciplinas') do
  # Já criados no step anterior com templates e disciplinas diferentes
end

Dado('não existem formulários não respondidos para minhas turmas') do
  # Garante que não há formulários para as turmas do aluno
  # Pode criar turmas para o aluno, mas sem formulários
  @disciplina = create(:disciplina, nome: "Disciplina Teste")
  @turma = create(:turma, codigo_turma: "Turma Vazia", disciplina: @disciplina)
  @aluno.turmas << @turma
  
  # Não cria formulários para essas turmas
end

Dado('existem formulários para minhas turmas') do
  # Similar ao step de formulários não respondidos
  @disciplina1 = create(:disciplina, nome: "Estruturas de Dados")
  @disciplina2 = create(:disciplina, nome: "Sistemas Operacionais")
  
  @turma1 = create(:turma, codigo_turma: "Turma A", disciplina: @disciplina1)
  @turma2 = create(:turma, codigo_turma: "Turma B", disciplina: @disciplina2)
  
  @aluno.turmas << [@turma1, @turma2]
  
  @admin_criador = create(:usuario, :admin, email: "admin_mixed@test.com")
  
  @template1 = create(:template, titulo: 'Avaliação Completa', criador: @admin_criador)
  @template2 = create(:template, titulo: 'Avaliação Parcial', criador: @admin_criador)
  
  create(:questao, template: @template1, enunciado: "Questão 1", tipo: 'Escala')
  create(:questao, template: @template2, enunciado: "Questão 2", tipo: 'Texto')
  
  @formulario_all1 = Formulario.create!(
    template: @template1,
    criador: @admin_criador,
    turmas: [@turma1]
  )
  
  @formulario_all2 = Formulario.create!(
    template: @template2,
    criador: @admin_criador,
    turmas: [@turma2]
  )
  
  @todos_formularios = [@formulario_all1, @formulario_all2]
end

Dado('eu já respondi alguns formulários') do
  # Cria resposta para o primeiro formulário
  @resposta_ja_feita = RespostaFormulario.create!(
    formulario: @formulario_all1,
    respondente: @aluno
  )
  
  # Cria resposta da questão
  RespostaQuestao.create!(
    resposta_formulario: @resposta_ja_feita,
    questao: @template1.questoes.first,
    valor_resposta: 3
  )
end

# --- QUANDO ---

Quando('acesso {string}') do |pagina_nome|
  case pagina_nome
  when "Meus Formulários"
    visit formularios_path
  end
  
  # Aguarda página carregar
  expect(page).to have_css('body')
end

# --- ENTÃO ---

Então('devo ver uma lista com os formulários pendentes') do
  # Verifica se há lista de formulários
  expect(page).to have_css('.formulario-item, .card, table, .list-group')
end

Então('para cada formulário devo ver o template, disciplina, turma e data de criação') do
  # Verifica informações básicas dos formulários pendentes
  @formularios_pendentes.each do |formulario|
    expect(page).to have_content(formulario.template.titulo)
    formulario.turmas.each do |turma|
      expect(page).to have_content(turma.disciplina.nome)
      expect(page).to have_content(turma.codigo_turma)
    end
  end
end

Então('deve haver um botão {string} ativo para cada formulário') do |texto_botao|
  # Conta formulários pendentes e verifica botões
  formularios_count = @formularios_pendentes ? @formularios_pendentes.count : Formulario.count
  expect(page).to have_link(texto_botao, count: formularios_count)
end

Então('a lista deve estar vazia') do
  # Verifica que não há formulários listados
  expect(page).not_to have_css('.formulario-item .card')
  # Ou verifica se há uma div/section vazia
  expect(page).not_to have_css('table tbody tr')
end

Então('devo ver apenas os formulários que ainda não respondi') do
  # Deve ver apenas o segundo formulário (que não foi respondido)
  expect(page).to have_content(@formulario_all2.template.titulo)
  
  # Não deve ver o primeiro formulário (que já foi respondido)
  expect(page).not_to have_content(@formulario_all1.template.titulo)
end

Então('não devo ver os formulários já respondidos') do
  # Verifica que formulários com respostas não aparecem
  if @resposta_ja_feita
    expect(page).not_to have_content(@formulario_all1.template.titulo)
  end
end

Então('deve haver um botão {string} apenas para formulários pendentes') do |texto_botao|
  # Verifica que há apenas um botão (para o formulário não respondido)
  expect(page).to have_link(texto_botao, count: 1)
end
