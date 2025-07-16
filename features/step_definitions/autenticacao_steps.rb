# features/step_definitions/autenticacao_steps.rb

# --- DADO ---
Dado('que eu sou um administrador cadastrado com o e-mail {string} e a senha {string}') do |email, senha|
  create(:usuario, :admin, email: email, password: senha)
end

Dado('que eu sou um usuário padrão cadastrado com o e-mail {string} e a senha {string}') do |email, senha|
  create(:usuario, email: email, password: senha)
end

Dado('que eu sou um usuário padrão cadastrado com a matrícula {string} e a senha {string}') do |matricula, senha|
  create(:usuario, matricula: matricula, password: senha)
end

Dado('que eu estou na página de login') do
  visit new_usuario_session_path
end

Dado('que eu sou um usuário cadastrado com o e-mail {string}') do |email|
  # This step uses FactoryBot to create a standard user in the test database.
  # We assume the default password in the factory is sufficient for this test.
  create(:usuario, email: email)
end

# --- QUANDO ---

Quando('eu preencho o campo {string} com {string}') do |nome_do_campo, valor|
  fill_in nome_do_campo, with: valor
end

Quando('eu insiro {string} no campo de {string}') do |valor, nome_do_campo|
  fill_in nome_do_campo, with: valor
end


Quando('clico no botão {string}') do |nome_do_botao|
  click_button nome_do_botao
end

# --- ENTÃO ---
Então('devo ser autenticado com sucesso e redirecionado para o dashboard de administração') do
  # A URL atual deve ser a do dashboard de admin
  expect(page).to have_current_path('/admin/dashboard')
  # E o conteúdo da página deve confirmar isso
  expect(page).to have_content('Dashboard de Administração')
end

Então('devo ser autenticado com sucesso e redirecionado para a minha página inicial') do
  # A URL atual deve ser a raiz do site
  expect(page).to have_current_path(root_path)
  # E o conteúdo deve ser o da página inicial do aluno
  expect(page).to have_content('Meus Formulários') # Ou o que for apropriado
end

Então('devo ver uma mensagem de erro indicando que {string}') do |mensagem_de_erro|
  # Verifica se o texto de erro aparece em qualquer lugar na página
  expect(page).to have_content(mensagem_de_erro)
end

Então('devo permanecer na página de login.') do
  # Verifica se a URL ainda é a da página de login
  expect(page).to have_current_path(new_usuario_session_path)
end

Então('não devo ter acesso ao dashboard de administração.') do
  # Verifica se a URL NÃO é a do dashboard de admin
  expect(page).not_to have_current_path('/admin/dashboard')
end

Então('o menu de navegação lateral deve exibir a opção {string}.') do |link_text|
  # This step finds a navigation menu (we assume it has a CSS id of 'side-nav')
  # and then checks if the text of the link is visible inside that menu.
  within('#side-nav') do
    expect(page).to have_content(link_text)
  end
end

Então('o menu de navegação não deve exibir a opção {string}.') do |link_text|
  # This step checks the entire page to ensure the specified link text
  # is NOT present. This is useful for verifying that regular users
  # don't see admin-only links.
  expect(page).not_to have_content(link_text)
end
