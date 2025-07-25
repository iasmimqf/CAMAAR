# Caminho: features/step_definitions/definicao_de_senha_steps.rb

# --- DADO (Setup do Cenário) ---

##
# Dado: Que o usuário solicitou uma redefinição de senha.
#
# Descrição: Cria um usuário com uma senha temporária e simula a solicitação
#    de redefinição de senha, gerando um token de redefinição.
# Argumentos:
#    - `email` (String): O e-mail do usuário que solicitou a redefinição.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Usuario` no banco de dados.
#    - Define as variáveis de instância `@user` e `@reset_token`.
#    - Pode enfileirar um e-mail de redefinição de senha (dependendo da configuração do Devise).
Dado('que o usuário {string} solicitou uma redefinição de senha') do |email|
  # Este passo continua o mesmo, pois prepara os dados no banco.
  @user = FactoryBot.create(:usuario, email: email, password: "SenhaEsquecida!123")
  @reset_token = @user.send_reset_password_instructions
end


# --- QUANDO (Ação do Usuário, agora como uma chamada de API) ---

##
# Quando: Eu visito a página de redefinição de senha com o token do usuário.
#
# Descrição: Este passo não simula uma visita a uma página HTML, mas sim
#    prepara o contexto para uma chamada de API, armazenando o token de
#    redefinição de senha para uso na requisição `PUT` subsequente.
# Argumentos:
#    - `email` (String): O e-mail do usuário cujo token está sendo usado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
Quando('eu visito a página de redefinição de senha com o token do usuário {string}') do |email|
  # Não visitamos uma página, apenas guardamos o token para usar na requisição.
  # A ação real acontecerá no passo de "clicar no botão".
end

##
# Quando: Eu preencho um campo com um valor.
#
# Descrição: Este passo não simula o preenchimento de campos em um formulário HTML,
#    mas sim armazena os valores fornecidos (nova senha e confirmação) em um hash
#    `@params`, que será usado para construir o corpo da requisição de API.
# Argumentos:
#    - `campo` (String): O nome do campo (e.g., "Nova Senha", "Confirmação de Senha").
#    - `valor` (String): O valor a ser preenchido no campo.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Modifica a variável de instância `@params`.
Quando('eu preencho o campo {string} com {string}') do |campo, valor|
  # Em vez de preencher campos, guardamos os dados para enviar na requisição.
  @params ||= {}
  # Mapeia o nome do campo para a chave correta do parâmetro
  chave = (campo == "Nova Senha") ? :password : :password_confirmation
  @params[chave] = valor
end

##
# Quando: Eu clico no botão "Alterar minha senha".
#
# Descrição: Este passo simula a submissão do formulário de redefinição de senha
#    através de uma chamada de API `PUT` para o endpoint `/api/v1/password`.
#    Ele utiliza o token de redefinição e as senhas armazenadas em `@params`.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Envia uma requisição HTTP PUT para a aplicação.
#    - Popula a variável global `last_response` com a resposta da requisição.
#    - Pode alterar a senha de um usuário no banco de dados.
Quando('clico no botão Alterar minha senha') do
  # Este é o passo que realmente faz a chamada para a API
  put '/api/v1/password', {
    reset_password_token: @reset_token,
    password: @params[:password],
    password_confirmation: @params[:password_confirmation]
  }
end

##
# Quando: Eu tento submeter a redefinição com um token inválido.
#
# Descrição: Simula uma tentativa de redefinição de senha usando um token
#    explicitamente inválido. Envia uma requisição `PUT` para a API de redefinição
#    de senha com o token inválido e senhas genéricas.
# Argumentos:
#    - `invalid_token` (String): Um token de redefinição de senha inválido.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Envia uma requisição HTTP PUT para a aplicação.
#    - Popula a variável global `last_response` com a resposta da requisição,
#      que deve indicar um erro.
Quando('eu tento submeter a redefinição com o token inválido {string}') do |invalid_token|
  # This step now makes the actual API call with the bad token
  put '/api/v1/password', {
    reset_password_token: invalid_token,
    password: 'any_password',
    password_confirmation: 'any_password'
  }
end

# --- ENTÃO (Verificação do Resultado) ---

##
# Então: Eu devo ser redirecionado para a página de.
#
# Descrição: Em um contexto de API, este passo verifica se a requisição
#    resultou em um status HTTP 200 (OK), indicando sucesso, já que não
#    há redirecionamento de página em chamadas de API bem-sucedidas.
# Argumentos:
#    - `path` (String): O caminho para o qual se esperaria um redirecionamento
#      em um cenário de UI (mas que é verificado como 200 OK na API).
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('eu devo ser redirecionado para a página de {string}') do |path|
  # Em uma API de sucesso, não há redirecionamento, apenas uma resposta 200 OK.
  expect(last_response.status).to eq(200)
end
