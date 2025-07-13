# features/step_definitions/visualizacao_template_steps.rb

# --- DADOS BASE ---

Dado('existem os seguintes templates: {string}') do |templates_string|
  # Parse a string de templates separados por vírgula
  template_names = templates_string.split(',').map(&:strip)
  
  # Cria os templates
  template_names.each do |nome|
    # Usa @admin ou @admin_user dependendo de qual está definido
    criador = @admin || @admin_user
    template = create(:template, titulo: nome, criador: criador)
    # Adiciona uma questão para satisfazer a validação
    create(:questao, template: template, enunciado: 'Questão de exemplo', tipo: 'Texto')
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
    
    # Se não estamos autenticados, faz login
    if page.has_content?('Para continuar, faça login') || page.has_content?('Log in')
      user = @admin_user || @admin
      if user
        page.driver.post usuario_session_path, {
          'usuario[login]' => user.email,
          'usuario[password]' => 'password123'
        }
        visit admin_templates_path
      end
    end
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
