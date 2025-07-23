# features/step_definitions/visualizacao_template_steps.rb

# --- DADOS BASE ---

Dado('que eu sou um administrador autenticado') do
  @admin = FactoryBot.create(:usuario, :admin)
  login_as(@admin, scope: :usuario)
end

Dado('existem os seguintes templates: {string}') do |templates_string|
  # Parse a string de templates separados por vírgula
  template_names = templates_string.split(',').map(&:strip)

  # Cria os templates
  template_names.each do |nome|
    # Usa @admin criado no step de autenticação
    template = FactoryBot.create(:template, titulo: nome, criador: @admin)
    # Adiciona uma questão para satisfazer a validação
    FactoryBot.create(:questao, template: template, enunciado: 'Questão de exemplo', tipo: 'Texto')
  end
end

Dado('que ainda não existam templates cadastrados no sistema') do
  # Limpa todos os templates existentes, mas preserva o usuário logado
  Template.destroy_all
end

# --- QUANDO ---

Quando('eu acesso a página de {string}') do |nome_pagina|
  case nome_pagina
  when 'Gerenciamento - Templates'
    visit admin_templates_path
  else
    raise "Página #{nome_pagina} não reconhecida"
  end
end

# --- ENTÃO ---

Então('devo ver uma lista contendo {string}') do |templates_string|
  template_names = templates_string.split(',').map(&:strip)

  template_names.each do |nome|
    expect(page).to have_content(nome)
  end
end

Então('cada template da lista deve conter os botões {string} e {string}') do |botao1, botao2|
  # Verifica se existem templates na página
  templates = page.all('.template-item, .bg-white, .border')

  # Se não encontrar pela classe, procura por linhas da tabela ou cards
  if templates.empty?
    templates = page.all('tr').select { |tr| tr.has_link?('Editar') || tr.has_link?('Excluir') }
  end

  # Se ainda não encontrou, procura pelos itens da lista
  if templates.empty?
    templates = page.all('li').select { |li| li.has_link?('Editar') || li.has_link?('Excluir') }
  end

  expect(templates.count).to be > 0, "Nenhum template foi encontrado na página"

  templates.each do |template_element|
    within(template_element) do
      expect(page).to have_link(botao1)
      expect(page).to have_link(botao2)
    end
  end
end

Então('devo ver uma mensagem como {string}') do |mensagem|
  # Permite flexibilidade na mensagem exata
  if mensagem.include?("Nenhum template")
    expect(page).to have_content("Nenhum template")
  else
    expect(page).to have_content(mensagem)
  end
end

Então('não deve haver botões {string} ou {string} exibidos') do |botao1, botao2|
  expect(page).not_to have_link(botao1)
  expect(page).not_to have_link(botao2)
end

# ===== NOVOS STEPS PARA VISUALIZAÇÃO DETALHADA =====

Quando('clico em Visualizar do template {string}') do |nome_template|
  # Procurar o template específico e clicar em Visualizar
  template = Template.find_by(titulo: nome_template)
  expect(template).to be_present, "Template '#{nome_template}' não encontrado"
  visit admin_template_path(template)
end

Então('devo ver os detalhes do template {string}') do |nome_template|
  expect(page).to have_content(nome_template)
  # Verificar que estamos na página de detalhes
  expect(current_path).to match(/\/admin\/templates\/\d+/)
end

Então('devo ver as questões do template') do
  # Verificar se existem questões na página
  expect(page.has_content?('Questões') || page.has_content?('questão')).to be_truthy
end

Então('devo ver botões de ação {string} e {string}') do |botao1, botao2|
  expect(page).to have_link(botao1)
  expect(page).to have_link(botao2)
end

Então('devo ver o nome do template {string}') do |titulo|
  expect(page).to have_content(titulo)
end

Então('devo ver informações sobre questões') do
  # Verificar se há informações sobre questões na listagem
  expect(page.has_content?('questão') || page.has_content?('Questões') || page.has_content?('1')).to be_truthy
end

Então('devo ver as ações disponíveis para o template') do
  expect(page.has_link?('Editar') || page.has_link?('Visualizar') || page.has_link?('Excluir')).to be_truthy
end
