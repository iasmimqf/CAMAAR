# Caminho: features/step_definitions/authenticacao_steps.rb

# --- DADO (Setup do Cenário) ---

##
# Define um administrador cadastrado para o cenário de teste.
#
# Descrição: Cria um usuário com privilégios de administrador usando FactoryBot,
#    com o e-mail e senha fornecidos. Armazena os dados do usuário para uso posterior.
# Argumentos:
#    - `email` (String): O endereço de e-mail do administrador.
#    - `senha` (String): A senha do administrador.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Usuario` no banco de dados.
#    - Define a variável de instância `@user_data`.
Dado('que eu sou um administrador cadastrado com o e-mail {string} e a senha {string}') do |email, senha|
  @user_data = { email: email, password: senha }
  FactoryBot.create(:usuario, :admin, email: email, password: senha)
end

##
# Define um usuário padrão cadastrado para o cenário de teste.
#
# Descrição: Cria um usuário padrão (não administrador) usando FactoryBot,
#    com o e-mail e senha fornecidos. Armazena os dados do usuário para uso posterior.
# Argumentos:
#    - `email` (String): O endereço de e-mail do usuário padrão.
#    - `senha` (String): A senha do usuário padrão.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Usuario` no banco de dados.
#    - Define a variável de instância `@user_data`.
Dado('que eu sou um usuário padrão cadastrado com o e-mail {string} e a senha {string}') do |email, senha|
  @user_data = { email: email, password: senha }
  FactoryBot.create(:usuario, email: email, password: senha)
end

##
# Define um usuário padrão cadastrado por matrícula para o cenário de teste.
#
# Descrição: Cria um usuário padrão (não administrador) usando FactoryBot,
#    com a matrícula e senha fornecidas. Armazena os dados do usuário para uso posterior.
# Argumentos:
#    - `matricula` (String): A matrícula do usuário padrão.
#    - `senha` (String): A senha do usuário padrão.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Usuario` no banco de dados.
#    - Define a variável de instância `@user_data`.
Dado('que eu sou um usuário padrão cadastrado com a matrícula {string} e a senha {string}') do |matricula, senha|
  @user_data = { matricula: matricula, password: senha }
  FactoryBot.create(:usuario, matricula: matricula, password: senha)
end

# --- QUANDO (A Ação Principal) ---

##
# Insere um valor em um campo de login.
#
# Descrição: Armazena o valor fornecido no hash `@login_params` sob uma chave
#    derivada do nome do campo (e.g., 'e-mail' ou 'senha'), preparando os parâmetros
#    para a requisição de login.
# Argumentos:
#    - `valor` (String): O valor a ser inserido (e-mail, matrícula ou senha).
#    - `campo` (String): O nome do campo (e.g., "e-mail" ou "senha").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Modifica a variável de instância `@login_params`.
Quando('eu insiro {string} no campo {string}') do |valor, campo|
  @login_params ||= {}
  @login_params[campo.downcase.split.first] = valor # Guarda 'e-mail' ou 'senha'
end

##
# Simula o clique no botão "Entrar" para realizar o login.
#
# Descrição: Constrói os parâmetros da requisição de login usando os dados
#    preparados em `@login_params` e envia uma requisição POST para o endpoint
#    de login do Devise (`/usuarios/sign_in.json`).
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Envia uma requisição HTTP POST para a aplicação.
#    - Popula a variável global `last_response` com a resposta da requisição.
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

##
# Verifica se a autenticação foi bem-sucedida e o redirecionamento para o dashboard de administração.
#
# Descrição: Assegura que o status da resposta HTTP seja 200 (OK),
#    e que o JSON de resposta contenha os dados corretos do usuário,
#    confirmando que o e-mail corresponde ao esperado e que o usuário é um administrador.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas, indicando falha no teste.
Então('devo ser autenticado com sucesso e redirecionado para o dashboard de administração') do
  expect(last_response.status).to eq(200)

  json_response = JSON.parse(last_response.body)
  expect(json_response['data']['email']).to eq(@user_data[:email])
  expect(json_response['data']['admin']).to be true
end

##
# Verifica se a autenticação foi bem-sucedida e o redirecionamento para a página inicial do usuário padrão.
#
# Descrição: Assegura que o status da resposta HTTP seja 200 (OK),
#    e que o JSON de resposta confirme que o usuário não é um administrador.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas, indicando falha no teste.
Então('devo ser autenticado com sucesso e redirecionado para a minha página inicial') do
  expect(last_response.status).to eq(200)

  json_response = JSON.parse(last_response.body)
  expect(json_response['data']['admin']).to be false
end

##
# Verifica se uma mensagem de erro específica é exibida.
#
# Descrição: Assegura que o status da resposta HTTP seja 401 (Unauthorized)
#    e que o JSON de resposta contenha a mensagem de erro esperada.
# Argumentos:
#    - `error_message` (String): A mensagem de erro esperada na resposta.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas, indicando falha no teste.
Então('devo ver uma mensagem de erro indicando que {string}') do |error_message|
  expect(last_response.status).to eq(401) # Unauthorized

  json_response = JSON.parse(last_response.body)
  expect(json_response['error']).to eq(error_message)
end

##
# Verifica se o usuário permanece na página de login (status 401).
#
# Descrição: Assegura que o status da resposta HTTP seja 401 (Unauthorized),
#    indicando que o login falhou e o usuário não foi redirecionado para fora
#    da página de login.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas, indicando falha no teste.
Então('devo permanecer na página de login') do
  expect(last_response.status).to eq(401)
end

##
# Verifica se o usuário não tem acesso ao dashboard de administração.
#
# Descrição: Assegura que o status da resposta HTTP seja 401 (Unauthorized),
#    confirmando que o usuário não obteve acesso ao dashboard de administração.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas, indicando falha no teste.
Então('não devo ter acesso ao dashboard de administração') do
  expect(last_response.status).to eq(401)
end
