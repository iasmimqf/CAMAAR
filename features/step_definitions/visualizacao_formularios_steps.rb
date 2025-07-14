# features/step_definitions/visualizacao_formularios_steps.rb

# --- DADO ---

Dado('que eu esteja na página de formulários {string}') do |pagina|
  case pagina
  when 'Gerenciamento'
    visit admin_root_path rescue visit root_path
  else
    # Para outras páginas, apenas confirma que estamos logados
    expect(@admin).to be_present
  end
end

Dado('existem formulários criados a partir de templates existentes') do
  # Usa @admin_user que é criado no step de autenticação
  admin_criador = @admin_user || @admin
  
  # Cria template primeiro com o admin logado
  @template1 = create(:template, titulo: 'Avaliação Docente', criador: admin_criador)
  create(:questao, template: @template1, enunciado: 'Como você avalia a disciplina?', tipo: 'Escala')
  
  @template2 = create(:template, titulo: 'Avaliação Infraestrutura', criador: admin_criador)
  create(:questao, template: @template2, enunciado: 'Como você avalia a infraestrutura?', tipo: 'Texto')
  
  # Cria disciplinas e turmas
  disciplina1 = create(:disciplina, nome: 'Programação Orientada a Objetos')
  disciplina2 = create(:disciplina, nome: 'Engenharia de Software')
  
  turma1 = create(:turma, codigo_turma: '001', disciplina: disciplina1)
  turma2 = create(:turma, codigo_turma: '002', disciplina: disciplina2)
  turma3 = create(:turma, codigo_turma: '003', disciplina: disciplina1)
  
  # Cria formulários com turmas associadas diretamente
  @formulario1 = Formulario.new(template: @template1, criador: admin_criador)
  @formulario1.turmas = [turma1, turma2]
  @formulario1.save!
  
  @formulario2 = Formulario.new(template: @template2, criador: admin_criador)
  @formulario2.turmas = [turma3]
  @formulario2.save!
end

Dado('que ainda não existam formulários criados no sistema') do
  Formulario.destroy_all
end

# --- QUANDO ---

Quando('eu acesso a página de resultados {string}') do |pagina|
  case pagina
  when 'Resultados'
    visit resultados_admin_formularios_path
  else
    raise "Página '#{pagina}' não está mapeada nos step definitions"
  end
end

# --- ENTÃO ---

Então('devo ver uma tabela com os formulários criados') do
  expect(page).to have_selector('table')
  expect(page).to have_content('Formulários Criados')
  expect(page).to have_selector('thead') # Cabeçalho da tabela
  expect(page).to have_selector('tbody') # Corpo da tabela
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

Então('deve haver um botão {string} disponível para cada formulário') do |botao_texto|
  formularios_count = Formulario.count
  expect(formularios_count).to be > 0
  
  # Verifica se há o mesmo número de botões que formulários
  expect(page).to have_button(botao_texto, count: formularios_count)
end

Então('devo ver uma mensagem de formulários como {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('não deve haver nenhuma tabela ou botão {string} exibido') do |botao_texto|
  expect(page).not_to have_selector('table')
  expect(page).not_to have_button(botao_texto)
end
