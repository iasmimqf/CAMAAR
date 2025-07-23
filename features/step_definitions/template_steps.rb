# encoding: utf-8

# ===== STEPS DE AUTENTICAÇÃO E NAVEGAÇÃO =====

Dado('que eu sou um administrador autenticado no sistema') do
  @admin = FactoryBot.create(:usuario, :admin)
  login_as(@admin, scope: :usuario)
end

Dado('que estou autenticado como administrador') do
  @admin = FactoryBot.create(:usuario, :admin, email: 'admin@email.com', password: 'Password@123')
  login_as(@admin, scope: :usuario)
  visit admin_templates_path
end

Dado('estou na página de {string}') do |pagina|
  case pagina.downcase
  when 'gerenciamento de templates', 'criação de template'
    visit admin_templates_path
  when 'novo template'
    visit new_admin_template_path
  else
    raise "Página '#{pagina}' não reconhecida"
  end
end

Dado('que acesso a página de criação de templates') do
  visit new_admin_template_path
end

# ===== STEPS PARA TEMPLATES EXISTENTES =====

Dado('que existe um template chamado {string}') do |titulo|
  criador = @admin || FactoryBot.create(:usuario, :admin)
  @existing_template = FactoryBot.create(:template, titulo: titulo, criador: criador)
  FactoryBot.create(:questao, template: @existing_template, enunciado: 'Questão de exemplo', tipo: 'Texto')
end

Dado('o template possui {int} questões cadastradas') do |num_questoes|
  num_questoes.times do |i|
    FactoryBot.create(:questao, template: @existing_template, enunciado: "Questão #{i+1}", tipo: 'Texto')
  end
end

Dado('o template possui as seguintes questões:') do |table|
  table.hashes.each do |row|
    FactoryBot.create(:questao, 
      template: @existing_template, 
      enunciado: row['pergunta'], 
      tipo: row['tipo'].capitalize
    )
  end
end

Dado('o template não possui questões cadastradas') do
  @existing_template.questoes.destroy_all
end

Dado('existem {int} formulários criados baseados neste template') do |num_formularios|
  turma = FactoryBot.create(:turma)
  num_formularios.times do
    FactoryBot.create(:formulario, template: @existing_template, turmas: [turma])
  end
end

Dado('não existem formulários criados baseados neste template') do
  @existing_template.formularios.destroy_all
end

Dado('que existem os seguintes templates no sistema:') do |table|
  table.hashes.each do |row|
    template = FactoryBot.create(:template, titulo: row['titulo'], criador: @admin)
    
    # Criar questões
    row['questoes'].to_i.times do |i|
      FactoryBot.create(:questao, template: template, enunciado: "Questão #{i+1}", tipo: 'Texto')
    end
    
    # Criar formulários
    if row['formularios'].to_i > 0
      turma = FactoryBot.create(:turma)
      row['formularios'].to_i.times do
        FactoryBot.create(:formulario, template: template, turmas: [turma])
      end
    end
  end
end

# ===== STEPS PARA INTERAÇÕES DE CRIAÇÃO =====

Quando('eu clico no botão {string}') do |botao|
  case botao.downcase
  when 'novo template', 'criar template'
    click_link_or_button 'Novo Template'
  when 'adicionar questão'
    click_link_or_button 'Adicionar Questão'
  when 'salvar template'
    # Se já adicionou questões, não precisa clicar novamente
    unless page.has_content?("Template") && page.has_content?("salvo com sucesso")
      click_link_or_button 'Salvar Template'
    end
  when 'atualizar template'
    click_link_or_button 'Atualizar Template'
  else
    click_link_or_button botao
  end
end

Quando('preencho o título com {string}') do |titulo|
  fill_in 'template[titulo]', with: titulo
end

Quando('eu preencho o título do template com {string}') do |titulo|
  fill_in 'template[titulo]', with: titulo
end

Quando('adiciono as seguintes questões:') do |table|
  table.hashes.each_with_index do |row, index|
    # Adicionar nova questão se não for a primeira
    if index > 0
      click_link_or_button 'Adicionar Questão'
    end
    
    within ".questao-#{index}" do
      fill_in "template[questoes_attributes][#{index}][enunciado]", with: row['pergunta']
      select row['tipo'].capitalize, from: "template[questoes_attributes][#{index}][tipo]"
      
      if row['obrigatoria'] == 'Sim'
        check "template[questoes_attributes][#{index}][obrigatoria]"
      end
    end
  end
end

Quando('eu adiciono uma questão do tipo {string} com o texto {string}') do |tipo, texto|
  within('.questoes-container') do
    select tipo.capitalize, from: 'template[questoes_attributes][0][tipo]'
    fill_in 'template[questoes_attributes][0][enunciado]', with: texto
  end
end

Quando('eu adiciono uma questão múltipla escolha {string} com as opções:') do |pergunta, table|
  questao_index = all('.questao-item').count
  
  within('.questoes-container') do
    select 'Escala', from: "template[questoes_attributes][#{questao_index}][tipo]"
    fill_in "template[questoes_attributes][#{questao_index}][enunciado]", with: pergunta
    
    opcoes = table.raw.flatten.join(',')
    fill_in "template[questoes_attributes][#{questao_index}][opcoes]", with: opcoes
  end
end

# ===== STEPS PARA EDIÇÃO E VISUALIZAÇÃO =====

Quando('eu clico no botão {string} do template {string}') do |acao, titulo|
  within("tr", text: titulo) do
    case acao.downcase
    when 'editar'
      click_link 'Editar'
    when 'visualizar'
      click_link 'Visualizar'
    when 'excluir'
      click_link 'Excluir'
    end
  end
end

Quando('eu altero o título para {string}') do |novo_titulo|
  fill_in 'template[titulo]', with: novo_titulo
end

Quando('eu adiciono uma nova questão {string}') do |pergunta|
  click_link_or_button 'Adicionar Questão'
  questao_index = all('.questao-item').count - 1
  within("#questao_#{questao_index}") do
    fill_in "template[questoes_attributes][#{questao_index}][enunciado]", with: pergunta
  end
end

Quando('confirmo a exclusão no modal de confirmação') do
  accept_confirm
end

Quando('eu acesso a página de gerenciamento de templates') do
  visit admin_templates_path
end

Quando('clico em {string}') do |botao|
  click_link_or_button botao
end

# ===== STEPS PARA VERIFICAÇÕES DE SUCESSO =====

Então('eu devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('eu devo ser redirecionado para a lista de templates') do
  expect(current_path).to eq(admin_templates_path)
end

Então('o template {string} deve aparecer na lista') do |titulo|
  expect(page).to have_content(titulo)
end

Então('eu devo ver o template criado na lista com {int} questões') do |num_questoes|
  within('.templates-list') do
    expect(page).to have_content("#{num_questoes} questões")
  end
end

Então('eu devo ser redirecionado para a página de edição do template') do
  expect(current_path).to eq(edit_admin_template_path(@existing_template))
end

Então('devo ver o formulário preenchido com os dados atuais') do
  expect(find_field('template[titulo]').value).to eq(@existing_template.titulo)
end

Então('devo ver o template com o novo título {string}') do |titulo|
  expect(page).to have_content(titulo)
end

Então('eu devo ser redirecionado para a página de detalhes do template') do
  expect(current_path).to eq(admin_template_path(@existing_template))
end

Então('devo ver o título {string}') do |titulo|
  expect(page).to have_content(titulo)
end

Então('devo ver as {int} questões listadas') do |num_questoes|
  expect(page).to have_css('.questao-item', count: num_questoes)
end

Então('devo ver botões {string} e {string}') do |botao1, botao2|
  expect(page).to have_link(botao1)
  expect(page).to have_link(botao2)
end

# ===== STEPS PARA VALIDAÇÕES E ERROS =====

Então('eu devo ver mensagens de erro indicando:') do |table|
  table.raw.flatten.each do |erro|
    expect(page).to have_content(erro)
  end
end

Então('o template não deve ser criado') do
  expect(Template.count).to eq(0)
end

Então('eu devo permanecer na página de criação') do
  expect(current_path).to eq(new_admin_template_path)
end

Então('eu devo ver a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o template deve continuar na lista') do
  expect(page).to have_content(@existing_template.titulo)
end

Então('os formulários associados devem permanecer intactos') do
  expect(@existing_template.formularios.count).to be > 0
end

Então('o template {string} não deve mais aparecer na lista') do |titulo|
  expect(page).not_to have_content(titulo)
end

# ===== STEPS PARA LISTA DE TEMPLATES =====

Então('eu devo ver uma tabela com todos os templates') do
  expect(page).to have_css('table.templates-table')
  Template.all.each do |template|
    expect(page).to have_content(template.titulo)
  end
end

Então('cada template deve mostrar:') do |table|
  table.raw.first.each do |header|
    expect(page).to have_content(header.humanize)
  end
end

Então('para templates com formulários associados, o botão {string} deve estar desabilitado') do |botao|
  Template.joins(:formularios).distinct.each do |template|
    within("tr", text: template.titulo) do
      expect(page).to have_css("button[disabled], .btn-disabled", text: botao)
    end
  end
end

Então('para templates sem formulários, o botão {string} deve estar habilitado') do |botao|
  Template.left_joins(:formularios).where(formularios: { id: nil }).each do |template|
    within("tr", text: template.titulo) do
      expect(page).to have_css("button:not([disabled]):not(.btn-disabled)", text: botao)
    end
  end
end

Então('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('devo ver um botão {string}') do |botao|
  expect(page).to have_link_or_button(botao)
end

# ===== STEPS AUXILIARES PARA DEBUGGING =====

Então('eu vejo o estado atual da página') do
  puts "Página atual: #{current_path}"
  puts "Conteúdo da página:"
  puts page.html[0..1000] # Primeiros 1000 caracteres
end

Então('eu vejo os templates no banco') do
  puts "Templates no banco:"
  Template.all.each do |template|
    puts "- #{template.titulo} (#{template.questoes.count} questões, #{template.formularios.count} formulários)"
  end
end

# ===== STEPS FALTANTES PARA CRIAR_TEMPLATE.FEATURE =====

Quando('acesso a página de administração de templates') do
  visit admin_templates_path
end

Então('devo ver {string}') do |texto|
  expect(page).to have_content(texto)
end

Então('devo ver o botão {string}') do |botao|
  begin
    expect(page).to have_button(botao)
  rescue RSpec::Expectations::ExpectationNotMetError
    expect(page).to have_link(botao)
  end
end

Então('devo ver o campo {string}') do |campo|
  case campo.downcase
  when 'título do template'
    expect(page).to have_field('template[titulo]')
  else
    expect(page).to have_field(campo)
  end
end

Quando('adiciono uma questão do tipo {string} com enunciado {string}') do |tipo, enunciado|
  puts "🔍 Estado atual:"
  puts "URL: #{current_path}"
  puts "Página de new?: #{current_path == new_admin_template_path}"
  
  # Se estamos na página new, não podemos salvar sem questões
  # Precisamos verificar se existe funcionalidade para adicionar questões na página new
  if current_path == new_admin_template_path
    puts "📝 Tentando adicionar questão na página de criação"
    
    # Verifica se existe botão ou funcionalidade para adicionar questões
    if page.has_button?('Adicionar Questão', wait: 2)
      puts "✅ Botão 'Adicionar Questão' encontrado"
      click_button 'Adicionar Questão'
      
      # Preenche a questão
      within(all('.questao-item').last) do
        # Preenche os campos da questão
        fill_in 'Enunciado', with: enunciado
        select tipo, from: 'Tipo'
        
        if tipo == 'Escala'
          fill_in 'Opções (para escalas, separadas por vírgula)', with: '5,4,3,2,1'
        end
      end
    else
      puts "❌ Funcionalidade de adicionar questões não disponível na página new"
      puts "Tentando criar template vazio primeiro..."
      
      # Como não consegue adicionar questões na página new,
      # e a validação impede criar sem questões,
      # isso indica que o cenário não está alinhado com o fluxo da aplicação
      raise "A aplicação não permite criar templates sem questões, mas a página new não tem funcionalidade para adicionar questões antes do save"
    end
  else
    puts "📝 Adicionando questão na página atual: #{current_path}"
    
    # Para outras páginas (como edit), usa o fluxo normal
    if page.has_button?('Adicionar Questão', wait: 2)
      puts "✅ Botão 'Adicionar Questão' encontrado"
      click_button 'Adicionar Questão'
      
      # Aguarda a questão aparecer
      puts "⏳ Aguardando questão aparecer..."
      
      # Verifica se questão foi adicionada
      if page.has_css?('.questao-item', wait: 5)
        puts "✅ Questão adicionada. Preenchendo campos..."
        
        within(all('.questao-item').last) do
          puts "✅ Preenchendo questão com os nomes corretos dos campos..."
          
          # Encontra os campos dentro desta questão específica
          enunciado_field = find('input[name*="[enunciado]"]')
          tipo_field = find('select[name*="[tipo]"]')
          
          enunciado_field.set(enunciado)
          tipo_field.select(tipo)
          
          if tipo == 'Escala'
            opcoes_field = find('input[name*="[opcoes]"]')
            opcoes_field.set('5,4,3,2,1')
          end
          
          puts "✅ Questão preenchida com sucesso!"
        end
      else
        puts "❌ Questão não foi adicionada após clicar no botão"
        puts "Elementos .questao-item encontrados: #{all('.questao-item').count}"
        puts "HTML da página: #{page.html[0..1000]}"
        raise "Questão não foi adicionada"
      end
    else
      raise "Botão 'Adicionar Questão' não encontrado"
    end
  end
  
  puts "✅ Questão configurada"
end

Quando('clico em {string} do template {string}') do |acao, titulo_template|
  puts "🔍 Procurando template '#{titulo_template}' na página"
  puts "URL atual: #{current_path}"
  puts "Conteúdo da página:"
  puts page.html[0..2000]
  
  # Procura pelo template na lista e clica na ação correspondente
  # Usa uma abordagem mais robusta
  if page.has_content?(titulo_template, wait: 5)
    puts "✅ Template encontrado na página"
    
    # Tenta diferentes estratégias para encontrar o elemento
    template_element = nil
    
    # Estratégia 1: XPath mais genérico
    begin
      template_element = find(:xpath, "//li[contains(., '#{titulo_template}')]")
    rescue Capybara::ElementNotFound
      puts "❌ XPath li não funcionou"
    end
    
    # Estratégia 2: Buscar diretamente pelo link
    if template_element.nil?
      begin
        case acao.downcase
        when 'editar'
          link_text = 'Editar'
        when 'excluir', 'deletar'
          link_text = 'Excluir'
        when 'visualizar', 'ver'
          link_text = 'Visualizar'
        else
          link_text = acao
        end
        
        click_link link_text
        return
      rescue Capybara::ElementNotFound
        puts "❌ Link direto '#{link_text}' não funcionou"
      end
    end
    
    # Se encontrou o elemento, clica na ação
    if template_element
      within(template_element) do
        case acao.downcase
        when 'editar'
          click_link 'Editar'
        when 'excluir', 'deletar'
          click_link 'Excluir'
        when 'visualizar', 'ver'
          click_link 'Visualizar'
        else
          click_link acao
        end
      end
    else
      raise "Não foi possível encontrar o template '#{titulo_template}'"
    end
  else
    puts "❌ Template '#{titulo_template}' não encontrado na página"
    raise "Template '#{titulo_template}' não encontrado na página"
  end
end

Então('devo estar na página de listagem de templates') do
  expect(current_path).to eq(admin_templates_path)
end

Então('devo estar na página de edição do template') do
  # Verifica se estamos numa URL de edição
  expect(current_path).to match(%r{/admin/templates/\d+/edit})
end

Então('devo ver {string} na lista') do |texto|
  expect(page).to have_content(texto)
end

Quando('clico em {string} sem preencher dados') do |botao|
  click_link_or_button botao
end

Quando('clico em {string} sem adicionar questões') do |botao|
  click_link_or_button botao
end

Quando('adiciono uma questão do tipo {string} com enunciado {string} e opções {string}') do |tipo, enunciado, opcoes|
  puts "🔍 Adicionando questão com opções..."
  puts "Tipo: #{tipo}, Enunciado: #{enunciado}, Opções: #{opcoes}"
  
  # Usa a mesma lógica do step anterior
  if current_path.include?('/edit')
    puts "📝 Adicionando questão na página de edição"
    
    if page.has_button?('Adicionar Questão', wait: 2)
      click_button 'Adicionar Questão'
      
      # Aguarda a questão aparecer
      if page.has_css?('.questao-item', wait: 5)
        puts "✅ Questão adicionada. Preenchendo campos..."
        
        within(all('.questao-item').last) do
          puts "✅ Preenchendo questão com opções..."
          
          # Encontra os campos dentro desta questão específica
          enunciado_field = find('input[name*="[enunciado]"]')
          tipo_field = find('select[name*="[tipo]"]')
          
          enunciado_field.set(enunciado)
          tipo_field.select(tipo)
          
          if tipo.downcase.include?('escala') || opcoes.present?
            opcoes_field = find('input[name*="[opcoes]"]')
            opcoes_field.set(opcoes)
          end
          
          puts "✅ Questão com opções preenchida!"
        end
      else
        raise "Questão não foi adicionada"
      end
    else
      raise "Botão 'Adicionar Questão' não encontrado"
    end
  else
    raise "Step só funciona na página de edição"
  end
end

Então('devo ver a mensagem de sucesso para {string}') do |titulo|
  expect(page).to have_content("Template '#{titulo}' salvo com sucesso")
end

Então('o template deve ter {int} questões') do |num_questoes|
  template = Template.last
  expect(template.questoes.count).to eq(num_questoes)
end

Dado('que existe um template com título {string}') do |titulo|
  criador = @admin || FactoryBot.create(:usuario, :admin)
  @existing_template = FactoryBot.create(:template, titulo: titulo, criador: criador)
  FactoryBot.create(:questao, template: @existing_template, enunciado: 'Questão exemplo', tipo: 'Texto')
end

Quando('adiciono uma questão básica') do
  puts "🔍 Adicionando questão básica..."
  
  # Se estamos na página new, precisa salvar primeiro
  if current_path == new_admin_template_path
    puts "📝 Salvando template primeiro..."
    click_button 'Salvar Template'
    # Aguarda redirecionamento para listagem
    expect(page).to have_current_path(admin_templates_path)
    
    # Agora precisa navegar para edição do template recém-criado
    template_criado = Template.last
    visit edit_admin_template_path(template_criado)
  end
  
  # Agora está na página de edição - adiciona a questão
  if page.has_button?('Adicionar Questão', wait: 2)
    puts "✅ Botão 'Adicionar Questão' encontrado"
    click_button 'Adicionar Questão'
    
    # Aguarda a questão aparecer
    if page.has_css?('.questao-item', wait: 5)
      puts "✅ Questão adicionada. Preenchendo campos..."
      
      within(all('.questao-item').last) do
        # Encontra os campos dentro desta questão específica
        enunciado_field = find('input[name*="[enunciado]"]')
        tipo_field = find('select[name*="[tipo]"]')
        
        enunciado_field.set('Questão básica')
        tipo_field.select('Texto')
        
        puts "✅ Questão básica preenchida!"
      end
    else
      raise "Questão não foi adicionada"
    end
  else
    raise "Botão 'Adicionar Questão' não encontrado"
  end
end

Então('o template deve aparecer na lista de templates disponíveis') do
  expect(page).to have_content(@existing_template.titulo)
end

Então('devo ver a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o sistema não deve criar o template') do
  # Verifica que nenhum template foi criado
  expect(Template.count).to eq(0)
end

Quando('tento criar outro template com o mesmo título') do
  visit new_admin_template_path
  fill_in 'Título do Template', with: @existing_template.titulo
  click_button 'Salvar Template'
  
  # Verifica se o erro de validação aparece ou se foi criado
  if page.has_content?('Foram encontrados os seguintes erros')
    puts "✅ Erro de validação encontrado como esperado"
  else
    puts "⚠️ Template foi criado (pode indicar que a validação não está funcionando)"
  end
end

Quando('preencho o título do template') do
  # Vai para a página de criação se não estiver lá
  unless current_path == new_admin_template_path
    visit new_admin_template_path
  end
  
  fill_in 'Título do Template', with: 'Template Teste'
end

Quando('preencho apenas o título do template') do
  visit new_admin_template_path
  fill_in 'Título do Template', with: 'Template Somente Título'
end

Então('o botão de salvar deve permanecer desabilitado') do
  expect(page).to have_button('Salvar Template', disabled: true)
end

Quando('deixo o campo {string} em branco') do |campo|
  visit new_admin_template_path
  case campo.downcase
  when 'título', 'título do template'
    fill_in 'template[titulo]', with: ''
  else
    fill_in campo, with: ''
  end
end

Quando('não adiciono nenhuma questão') do
  # Não faz nada - deixa o template sem questões
end

Quando('adiciono uma questão do tipo {string} sem enunciado') do |tipo|
  puts "🔍 Adicionando questão sem enunciado..."
  
  # Funciona apenas na página de edição
  if current_path.include?('/edit')
    if page.has_button?('Adicionar Questão', wait: 2)
      click_button 'Adicionar Questão'
      
      # Aguarda a questão aparecer
      if page.has_css?('.questao-item', wait: 5)
        within(all('.questao-item').last) do
          # Preenche apenas o tipo, deixa enunciado vazio
          tipo_field = find('select[name*="[tipo]"]')
          tipo_field.select(tipo)
          
          # Enunciado fica vazio propositalmente
          puts "✅ Questão sem enunciado adicionada"
        end
      else
        raise "Questão não foi adicionada"
      end
    else
      raise "Botão 'Adicionar Questão' não encontrado"
    end
  else
    raise "Step só funciona na página de edição"
  end
end

Então('eu devo ver as mensagens de erro:') do |table|
  table.raw.flatten.each do |erro|
    expect(page).to have_content(erro)
  end
end

Então('eu devo permanecer na página de criação de template') do
  expect(current_path).to eq(new_admin_template_path)
end

Então('o template {string} não deve ser criado no sistema') do |titulo|
  expect(Template.where(titulo: titulo)).to be_empty
end
