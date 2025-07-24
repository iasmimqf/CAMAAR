# features/step_definitions/criar_formulario_steps.rb

# --- BEFORE/AFTER HOOKS ---
Before do
  # Limpeza mais seletiva para evitar problemas de foreign key
  Formulario.destroy_all
  ActionMailer::Base.deliveries.clear
end

# --- DADO ---
# Reutiliza o step de autenticação do template_steps.rb

Dado('existem templates de formulário cadastrados') do
  # Usa @admin ou @admin_user dependendo de qual está definido
  criador = @admin || @admin_user
  @template_avaliacao = create(:template, titulo: 'Avaliação Padrão', criador: criador)
  create(:questao, template: @template_avaliacao, enunciado: 'Como você avalia a disciplina?', tipo: 'Escala')

  @template_outro = create(:template, titulo: 'Avaliação Detalhada', criador: criador)
  create(:questao, template: @template_outro, enunciado: 'Comentários sobre a disciplina', tipo: 'Texto')
end

Dado('existem turmas ativas para o semestre atual') do
  @disciplina1 = create(:disciplina, nome: 'Banco de Dados')
  @disciplina2 = create(:disciplina, nome: 'Engenharia de Software')

  @turma01 = create(:turma, codigo_turma: 'Turma 01', disciplina: @disciplina1, semestre: '2025.1')
  @turma02 = create(:turma, codigo_turma: 'Turma 02', disciplina: @disciplina1, semestre: '2025.1')
  @turma03 = create(:turma, codigo_turma: 'Turma 03', disciplina: @disciplina2, semestre: '2025.1')
  @turma04 = create(:turma, codigo_turma: 'Turma 04', disciplina: @disciplina2, semestre: '2025.1')
end

Dado('a turma {string} já foi avaliada neste semestre') do |codigo_turma|
  turma = Turma.find_by(codigo_turma: codigo_turma)
  criador = @admin || @admin_user
  formulario_existente = build(:formulario, template: @template_avaliacao, criador: criador)
  formulario_existente.save(validate: false) # Pula validação para criar o formulário
  formulario_existente.turmas << turma
end

Dado('não existem templates de formulário cadastrados') do
  Template.destroy_all
end

Dado('não existem turmas ativas para o semestre atual') do
  Turma.destroy_all
end

# --- QUANDO ---
Quando('eu acesso a página de criação de formulário') do
  visit new_admin_formulario_path
end

Quando('eu seleciono o template {string}') do |template_nome|
  select template_nome, from: 'formulario[template_id]'
end

Quando('eu seleciono as turmas {string}, {string} e {string}') do |turma1, turma2, turma3|
  [ turma1, turma2, turma3 ].each do |turma_nome|
    turma = Turma.find_by(codigo_turma: turma_nome)
    check "turma_#{turma.id}" if turma
  end
end

Quando('eu seleciono a turma {string}') do |turma_nome|
  turma = Turma.find_by(codigo_turma: turma_nome)
  check "turma_#{turma.id}" if turma
end

Quando('eu não seleciono nenhuma turma') do
  # Não faz nada - deixa todas as turmas desmarcadas
end

Quando('eu clico em {string}') do |botao_texto|
  click_button botao_texto
end

# --- ENTÃO ---
Então('devo ver mensagem de sucesso de formulário {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('devo ver mensagem de erro de formulário {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

Então('eu devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('as turmas devem estar associadas ao novo formulário') do
  # Verifica se o formulário foi criado e tem as turmas associadas
  formulario = Formulario.last
  expect(formulario).to be_present
  expect(formulario.turmas.count).to be > 0

  # Verifica se a página atual mostra o sucesso
  expect(current_path).to eq(admin_formularios_path)
end

Então('o botão {string} deve estar desabilitado') do |botao_texto|
  # Verifica se o botão existe e está desabilitado
  expect(page).to have_button(botao_texto, disabled: true)
end
