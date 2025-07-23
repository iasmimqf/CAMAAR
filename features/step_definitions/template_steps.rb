# encoding: utf-8
# Step definitions específicos para CRIAÇÃO de templates (criar_template.feature)
# Para gerenciamento (editar, visualizar, excluir) usar gerenciamento_template_steps.rb

# ===== AUTENTICAÇÃO E NAVEGAÇÃO =====

Dado('que estou autenticado como administrador') do
  @admin = FactoryBot.create(:usuario, :admin)
  login_as(@admin, scope: :usuario)
end

# ===== NAVEGAÇÃO PARA CRIAÇÃO =====

Quando('acesso a página de administração de templates') do
  visit admin_templates_path
end

Dado('que acesso a página de criação de templates') do
  visit new_admin_template_path
end

# ===== TEMPLATES EXISTENTES PARA CENÁRIOS DE CRIAÇÃO =====

Dado('que existe um template com título {string}') do |titulo|
  @admin ||= FactoryBot.create(:usuario, :admin)
  @existing_template = FactoryBot.create(:template, titulo: titulo, criador: @admin)
end

Dado('que existe um template chamado {string}') do |titulo|
  @admin ||= FactoryBot.create(:usuario, :admin)
  @existing_template = FactoryBot.create(:template, titulo: titulo, criador: @admin)
  # Se já estamos em uma página de templates, recarregar para mostrar o template criado
  if current_path && current_path.include?('templates')
    visit current_path
  end
end

# ===== AÇÕES DE CRIAÇÃO =====

Quando('preencho o título com {string}') do |titulo|
  fill_in 'template[titulo]', with: titulo
end

Quando('clico em {string}') do |botao_texto|
  case botao_texto.downcase
  when 'salvar template'
    click_button 'Salvar Template'
  when 'cancelar'
    click_link 'Cancelar'
  when 'novo template'
    click_link 'Novo Template'
  when 'salvar'
    click_button 'Salvar'
  else
    click_link_or_button botao_texto
  end
end

Quando('clico em {string} sem preencher dados') do |botao|
  # Não preencher nada e clicar
  click_button botao
end

Quando('preencho apenas o título do template') do
  # Primeiro navegar para página de criação se não estivermos lá
  unless current_path && current_path.include?('new')
    visit new_admin_template_path
  end
  fill_in 'template[titulo]', with: 'Template Somente Título'
end

Quando('não adiciono nenhuma questão') do
  # Step vazio - apenas para legibilidade do cenário
end

Quando('deixo o campo {string} em branco') do |campo|
  case campo.downcase
  when 'título'
    # Primeiro navegar para página de criação se não estivermos lá
    unless current_path && current_path.include?('new')
      visit new_admin_template_path
    end
    fill_in 'template[titulo]', with: ''
  end
end

Quando('tento criar outro template com o mesmo título') do
  # Navegar para página de criação
  visit new_admin_template_path
  fill_in 'template[titulo]', with: @existing_template.titulo
end

# ===== AÇÕES COM QUESTÕES (para templates que já foram salvos) =====

Quando('clico em {string} do template {string}') do |acao, titulo|
  # Encontrar o template na listagem e clicar na ação
  within page.find('li', text: titulo) do
    click_link acao
  end
end

Quando('adiciono uma questão do tipo {string} com enunciado {string}') do |tipo, enunciado|
  click_button 'Adicionar Questão'
  
  within('.questao-item:last-child') do
    fill_in find('input[name*="[enunciado]"]')[:name], with: enunciado
    select tipo, from: find('select[name*="[tipo]"]')[:name]
  end
end

Quando('adiciono uma questão do tipo {string} com enunciado {string} e opções {string}') do |tipo, enunciado, opcoes|
  click_button 'Adicionar Questão'
  
  within('.questao-item:last-child') do
    fill_in find('input[name*="[enunciado]"]')[:name], with: enunciado
    select tipo, from: find('select[name*="[tipo]"]')[:name]
    
    if tipo.downcase == 'escala' && opcoes.present?
      fill_in find('input[name*="[opcoes]"]')[:name], with: opcoes
    end
  end
end

Quando('adiciono uma questão do tipo {string} sem enunciado') do |tipo|
  click_button 'Adicionar Questão'
  
  within('.questao-item:last-child') do
    # Deixar enunciado vazio propositalmente
    select tipo, from: find('select[name*="[tipo]"]')[:name]
  end
end

Quando('clico em {string} sem adicionar questões') do |botao|
  # Não adicionar questões e clicar
  click_button botao
end

# ===== VALIDAÇÕES E VERIFICAÇÕES =====

Então('devo ver {string}') do |texto|
  expect(page).to have_content(texto)
end

Então('devo ver o campo {string}') do |campo|
  case campo.downcase
  when 'título do template'
    expect(page).to have_field('template[titulo]')
  else
    expect(page).to have_field(campo)
  end
end

Então('devo ver o botão {string}') do |botao|
  # Pode ser botão ou link
  if page.has_button?(botao)
    expect(page).to have_button(botao)
  else
    expect(page).to have_link(botao)
  end
end

Então('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('devo ver a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('devo estar na página de listagem de templates') do
  expect(current_path).to eq(admin_templates_path)
end

Então('o sistema não deve criar o template') do
  # Verificar que ainda estamos na página de criação ou voltamos pra ela
  expect(current_path == '/admin/templates/new' || current_path.match(/\/admin\/templates\/new/) || current_path == '/admin/templates').to be_truthy
end

Então('o template deve ter {int} questões') do |quantidade|
  # Buscar template no banco de dados para verificar questões
  template = Template.find_by(titulo: 'Avaliação Completa')
  expect(template).to be_present
  expect(template.questoes.count).to eq(quantidade)
end

# ===== VALIDAÇÕES ESPECÍFICAS DE CRIAÇÃO =====

# (Steps de validação já definidos acima)
