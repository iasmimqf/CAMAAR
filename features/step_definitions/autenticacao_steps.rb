# --- DADO (Setup do Cenário) ---

Dado('que eu sou um administrador cadastrado com o e-mail {string} e a senha {string}') do |email, senha|
  @user_data = { email: email, password: senha }
  FactoryBot.create(:usuario, :admin, email: email, password: senha)
end

Dado('que eu sou um usuário padrão cadastrado com o e-mail {string} e a senha {string}') do |email, senha|
  @user_data = { email: email, password: senha }
  FactoryBot.create(:usuario, email: email, password: senha)
end

Dado('que eu sou um usuário padrão cadastrado com a matrícula {string} e a senha {string}') do |matricula, senha|
  @user_data = { matricula: matricula, password: senha }
  FactoryBot.create(:usuario, matricula: matricula, password: senha)
end

# --- QUANDO (A Ação Principal) ---

Quando('eu insiro {string} no campo {string}') do |valor, campo|
  @login_params ||= {}
  @login_params[campo.downcase.split.first] = valor # Guarda 'e-mail' ou 'senha'
end

Quando('clico no botão Entrar') do
  login_identifier = @login_params&.[]('e-mail') || @login_params&.[]('matrícula')
  password = @login_params&.[]('senha') || ''

  post '/usuarios/sign_in.json', {
    usuario: {
      login: login_identifier,
      password: password
    }
  }, headers: { "Content-Type" => "application/json" }
end

# --- ENTÃO (Verificação do Resultado) ---

Então('devo ser autenticado com sucesso e redirecionado para o dashboard de administração') do
  expect(last_response.status).to eq(200)

  json_response = JSON.parse(last_response.body)
  expect(json_response['data']['email']).to eq(@user_data[:email])
  expect(json_response['data']['admin']).to be true
end

Então('devo ser autenticado com sucesso e redirecionado para a minha página inicial') do
  expect(last_response.status).to eq(200)

  json_response = JSON.parse(last_response.body)
  expect(json_response['data']['admin']).to be false
end

Então('devo ver uma mensagem de erro indicando que {string}') do |error_message|
  expect(last_response.status).to eq(401) # Unauthorized

  json_response = JSON.parse(last_response.body)
  expect(json_response['error']).to eq(error_message)
end

Então('devo permanecer na página de login') do
  expect(last_response.status).to eq(401)
end

Então('não devo ter acesso ao dashboard de administração') do
  expect(last_response.status).to eq(401)
end
