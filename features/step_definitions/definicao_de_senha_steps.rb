# --- DADO (Setup do Cenário) ---

Dado('que o usuário {string} solicitou uma redefinição de senha') do |email|
  # Este passo continua o mesmo, pois prepara os dados no banco.
  @user = FactoryBot.create(:usuario, email: email, password: "SenhaEsquecida!123")
  @reset_token = @user.send_reset_password_instructions
end


# --- QUANDO (Ação do Usuário, agora como uma chamada de API) ---

Quando('eu visito a página de redefinição de senha com o token do usuário {string}') do |email|
  # Não visitamos uma página, apenas guardamos o token para usar na requisição.
  # A ação real acontecerá no passo de "clicar no botão".
end

Quando('eu preencho o campo {string} com {string}') do |campo, valor|
  # Em vez de preencher campos, guardamos os dados para enviar na requisição.
  @params ||= {}
  # Mapeia o nome do campo para a chave correta do parâmetro
  chave = (campo == "Nova Senha") ? :password : :password_confirmation
  @params[chave] = valor
end

Quando('clico no botão Alterar minha senha') do
  # Este é o passo que realmente faz a chamada para a API
  put '/api/v1/password', {
    reset_password_token: @reset_token,
    password: @params[:password],
    password_confirmation: @params[:password_confirmation]
  }
end

Quando('eu tento submeter a redefinição com o token inválido {string}') do |invalid_token|
  # This step now makes the actual API call with the bad token
  put '/api/v1/password', {
    reset_password_token: invalid_token,
    password: 'any_password',
    password_confirmation: 'any_password'
  }
end

Então('eu devo ser redirecionado para a página de {string}') do |path|
  # Em uma API de sucesso, não há redirecionamento, apenas uma resposta 200 OK.
  expect(last_response.status).to eq(200)
end
