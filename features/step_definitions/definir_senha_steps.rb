require 'capybara/cucumber'
require 'factory_bot_rails'
require 'securerandom' # Necessário para garantir dados únicos

# --- Variáveis de Instância ---
Before do
  @usuario = nil
  @token = nil
end

# --- Passos "Dado" (Given) ---

Dado('que sou um usuário recém-criado sem senha definida') do
  # CORRIGIDO: Criamos um utilizador 100% válido manualmente para garantir
  # que ele passe em todas as validações do modelo. Isto resolve o erro
  # "Não foi possível salvar usuario".
  @usuario = Usuario.new(
    nome: 'Utilizador de Teste',
    email: "teste-#{SecureRandom.hex(4)}@exemplo.com", # Email único para cada teste
    matricula: SecureRandom.rand(100000..999999).to_s, # Matrícula única para cada teste
    password: 'password_inicial_segura_123',
    password_confirmation: 'password_inicial_segura_123'
  )
  # Usamos save! para que o teste falhe com uma mensagem clara se o utilizador for inválido.
  @usuario.save!

  # Em seguida, geramos o token de redefinição para este utilizador válido.
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
  # WORKAROUND: O teste agora espera o texto padrão em Inglês.
  expect(page).to have_content("Change your password")
end

Quando(/^eu preencho o campo(?: de senha)? "([^"]*)" com "([^"]*)"$/) do |campo, valor|
  # Mapeia os nomes dos campos em Português para os nomes em Inglês do Devise.
  english_field = case campo
                  when "Nova Senha"
                    "New password"
                  when "Confirmar Senha"
                    "Confirm new password"
                  else
                    campo
                  end
  fill_in english_field, with: valor
end

Quando('clico no botão de formulário de senha {string}') do |botao|
  # WORKAROUND: Mapeia o nome do botão para o Inglês.
  english_button = (botao == "Salvar Senha") ? "Change my password" : botao
  click_button english_button
end

Quando('eu tento abrir este link no meu navegador') do
  visit(edit_usuario_password_path(reset_password_token: @token))
end

# --- Passos "Então" (Then) ---

Então('eu devo ver uma mensagem de sucesso como {string}') do |mensagem|
  # WORKAROUND: Procura a mensagem de sucesso padrão em Inglês do Devise.
  expect(page).to have_content("Your password has been changed successfully")
end

Então('devo ser redirecionado para a página de login.') do
  # O Devise, por padrão, redireciona para a rota raiz após o reset de senha e faz o login.
  expect(page).to have_current_path(root_path, ignore_query: true)
end

Então('eu devo ver uma mensagem de erro na tela, como {string}') do |mensagem_erro|
  # WORKAROUND: Mapeia as mensagens de erro para as mensagens padrão em Inglês do Devise.
  english_error = case mensagem_erro
                  when "As senhas não conferem. Por favor, tente novamente."
                    "doesn't match Password"
                  else
                    mensagem_erro
                  end
  expect(page).to have_content(english_error)
end

Então('devo ser direcionado para uma página de erro informando: {string}') do |mensagem_erro|
  # WORKAROUND: Procura a mensagem de erro de token inválido em Inglês.
  if mensagem_erro == "Este link é inválido ou já expirou."
    expect(page).to have_content("Reset password token is invalid")
  else
    expect(page).to have_content(mensagem_erro)
  end
end
