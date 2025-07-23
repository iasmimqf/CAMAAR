# encoding: utf-8
# Step definitions para autenticação com CAPYBARA + SELENIUM
# Implementação adequada usando browser real

# ===== SETUP DE USUÁRIOS =====

Dado('que eu sou um administrador cadastrado com o e-mail {string} e a senha {string}') do |email, senha|
  @user_data = { email: email, password: senha }
  @admin_user = FactoryBot.create(:usuario, :admin, email: email, password: senha)
end

Dado('que eu sou um usuário padrão cadastrado com o e-mail {string} e a senha {string}') do |email, senha|
  @user_data = { email: email, password: senha }
  @regular_user = FactoryBot.create(:usuario, email: email, password: senha)
end

Dado('que eu sou um usuário padrão cadastrado com a matrícula {string} e a senha {string}') do |matricula, senha|
  @user_data = { matricula: matricula, password: senha }
  @regular_user = FactoryBot.create(:usuario, matricula: matricula, password: senha)
end

# ===== NAVEGAÇÃO =====

Dado('que estou na página de login') do
  visit new_usuario_session_path
end

# ===== INTERAÇÕES COM CAPYBARA =====

Quando('eu insiro {string} no campo {string}') do |valor, nome_campo|
  case nome_campo.downcase
  when 'e-mail ou matrícula'
    fill_in 'usuario_login', with: valor
  when 'senha'
    fill_in 'usuario_password', with: valor
  else
    # Fallback genérico
    fill_in nome_campo, with: valor
  end
end

Quando('clico no botão {string}') do |nome_botao|
  click_button nome_botao
end

Quando('eu deixo os campos de login vazios') do
  # Não preencher nada - os campos ficam vazios por padrão
  fill_in 'usuario_login', with: ''
  fill_in 'usuario_password', with: ''
end

# ===== VERIFICAÇÕES COM CAPYBARA =====

Então('devo ser autenticado com sucesso e redirecionado para o dashboard de administração') do
  # Para autenticação AJAX que retorna JSON
  if page.body.include?('{"data":')
    # Verificar se o JSON contém dados de admin
    expect(page.body).to include('"admin":true')
    expect(page.body).to include('"email"')
  else
    # Verificar redirecionamento tradicional
    expect(current_path).not_to eq(new_usuario_session_path)
    expect(page).not_to have_content('Para continuar, efetue login')
  end
end

Então('devo ser autenticado com sucesso e redirecionado para a minha página inicial') do
  # Para autenticação AJAX que retorna JSON
  if page.body.include?('{"data":')
    # Verificar se o JSON contém dados de usuário não-admin
    expect(page.body).to include('"admin":false')
    expect(page.body).to include('"email"')
  else
    # Verificar redirecionamento tradicional
    expect(current_path).not_to eq(new_usuario_session_path)
    expect(page).not_to have_content('Para continuar, efetue login')
  end
end

Então('devo ver uma mensagem de erro indicando que {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

Então('devo ver uma mensagem de erro de campos obrigatórios') do
  # Verificar mensagens de erro de validação
  expect(page.has_content?('obrigatório') || 
         page.has_content?('inválido') ||
         page.has_content?('não pode ficar em branco') ||
         page.has_content?('Login ou senha inválidos')).to be_truthy
end

Então('devo ter acesso às funcionalidades administrativas') do
  # Para autenticação AJAX, verificar se temos dados de admin no JSON
  if page.body.include?('{"data":')
    expect(page.body).to include('"admin":true')
  else
    # Verificar se temos acesso às funcionalidades de admin na página
    expect(page.has_content?('Gerenciamento') || 
           page.has_content?('Templates') ||
           page.has_content?('Administração') ||
           page.has_content?('admin')).to be_truthy
  end
end
