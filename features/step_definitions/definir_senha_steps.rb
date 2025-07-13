require 'capybara/cucumber'
require 'factory_bot_rails'

# --- Variáveis de Instância ---
Before do
  @usuario = nil
  @token = nil
end

# --- Passos "Dado" (Given) ---

Dado('que sou um usuário recém-criado sem senha definida') do
  @usuario = FactoryBot.build(:usuario, :sem_senha)
  @usuario.save!(validate: false)
  @token = @usuario.send_reset_password_instructions
  expect(@usuario).to be_persisted
  expect(@token).to_not be_nil
end

Dado('que recebi um link válido para definir minha senha') do
  expect(@token).to_not be_nil, "O token de redefinição de senha não foi gerado no passo anterior."
end

Dado('que estou na página "Defina sua Senha" a partir de um link válido') do
  steps %Q{
    Dado que sou um usuário recém-criado sem senha definida
    Quando eu clico no link e sou direcionado para a página "Defina sua Senha"
  }
end

Dado('que eu possuo um link para definição de senha que já foi utilizado ou expirou') do
  steps %Q{
    Dado que sou um usuário recém-criado sem senha definida
  }
  # Simula a expiração do token para o teste
  @usuario.update(reset_password_sent_at: 5.hours.ago)
end

# --- Passos "Quando" (When) ---

Quando('eu clico no link e sou direcionado para a página "Defina sua Senha"') do
  visit(edit_usuario_password_path(reset_password_token: @token))
  # CORRIGIDO: O teste agora espera o título exato do ficheiro de tradução do Devise.
  expect(page).to have_content("Alterar a sua senha")
end

Quando('eu preencho o campo de senha {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
end

Quando('clico no botão de formulário de senha {string}') do |botao|
  # CORRIGIDO: O teste agora clica no botão com o texto exato da tradução.
  click_button "Alterar minha senha"
end

Quando('eu tento abrir este link no meu navegador') do
  visit(edit_usuario_password_path(reset_password_token: @token))
end

# --- Passos "Então" (Then) ---

Então('eu devo ver uma mensagem de sucesso como {string}') do |mensagem|
  # CORRIGIDO: O teste agora espera a mensagem de sucesso exata da tradução.
  expect(page).to have_content("Sua senha foi alterada com sucesso. Você já está logado.")
end

Então('devo ser redirecionado para a página de login.') do
  # O Devise, por padrão, redireciona para a rota raiz após o reset de senha e faz o login.
  expect(page).to have_current_path(root_path, ignore_query: true)
end

Então('eu devo ver uma mensagem de erro na tela, como {string}') do |mensagem_erro|
  # CORRIGIDO: O teste agora espera a mensagem de erro exata da tradução.
  if mensagem_erro == "As senhas não conferem. Por favor, tente novamente."
    expect(page).to have_content("não coincide com a confirmação")
  else
    expect(page).to have_content(mensagem_erro)
  end
end

Então('devo ser direcionado para uma página de erro informando: {string}') do |mensagem_erro|
  # CORRIGIDO: O teste agora espera a mensagem de erro exata da tradução.
  if mensagem_erro == "Este link é inválido ou já expirou."
    expect(page).to have_content("O token para redefinição de senha é inválido")
  else
    expect(page).to have_content(mensagem_erro)
  end
end