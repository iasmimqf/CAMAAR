# features/step_definitions/importacao_steps.rb
require 'jwt' # Garante que a biblioteca JWT seja carregada

# --- DADO (Setup do Cenário) ---

Dado('que eu estou autenticado como um {string}') do |tipo_usuario|
  # 1. Cria o utilizador de teste com uma senha conhecida
  @user = FactoryBot.create(:usuario, :admin, password: 'PasswordValida!123')

  # 2. Faz uma requisição de LOGIN real para a API para obter um token
  login_params = {
    usuario: {
      login: @user.email,
      password: 'PasswordValida!123'
    }
  }
  # Garante que está a usar a rota de login correta da sua aplicação
  post '/usuarios/sign_in.json', login_params

  # Garante que o login foi bem-sucedido antes de continuar
  unless last_response.status == 200
    raise "Falha ao autenticar o utilizador de teste. Resposta: #{last_response.status} #{last_response.body}"
  end

  # 3. Captura o token real do cabeçalho da resposta
  @auth_headers = { 'Authorization' => last_response.headers['Authorization'] }
  expect(@auth_headers['Authorization']).to be_present, "A API de login não retornou um token de autorização. Verifique a configuração em config/initializers/devise-jwt.rb"
end


# --- QUANDO (Ação da API) ---

Quando('eu envio o arquivo {string} para o endpoint de importação de turmas') do |filename|
  file_path = Rails.root.join('features', 'support', 'test_files', filename)
  file = Rack::Test::UploadedFile.new(file_path, 'application/json')
  
  # Usa o token capturado para fazer a requisição autenticada
  post '/admin/importacoes/importar_turmas', params: { file: file }, headers: @auth_headers
end

Quando('eu envio o arquivo {string} para o endpoint de importação de alunos') do |filename|
  file_path = Rails.root.join('features', 'support', 'test_files', filename)
  file = Rack::Test::UploadedFile.new(file_path, 'application/json')

  # Usa o token capturado para fazer a requisição autenticada
  post '/admin/importacoes/importar_alunos', params: { file: file }, headers: @auth_headers
end


# --- ENTÃO (Verificação da Resposta da API) ---

Então('a resposta da API deve ser de sucesso') do
  # Adiciona um puts de depuração em caso de falha para vermos a resposta
  puts "DEBUG: Resposta da API com falha: #{last_response.body}" unless [200, 201].include?(last_response.status)
  
  expect(last_response.status).to be_in([200, 201]) # OK ou Created
end

Então('a resposta da API deve ser um erro com a mensagem {string}') do |message|
  expect(last_response.status).to be_in([400, 422]) # Bad Request ou Unprocessable Entity
  
  json_response = JSON.parse(last_response.body)
  response_message = json_response['alert'] || json_response['errors']&.first
  expect(response_message).to include(message)
end

# Os seus steps que verificam o banco de dados já estão perfeitos
Então('a turma {string} deve ser criada no sistema.') do |nome_disciplina|
  disciplina = Disciplina.find_by(name: nome_disciplina)
  expect(disciplina).not_to be_nil
  expect(disciplina.turmas).not_to be_empty
end

Então('o usuário {string} deve ser criado e associado à turma {string}.') do |nome_usuario, nome_disciplina|
  usuario = Usuario.find_by(nome_completo: nome_usuario)
  expect(usuario).not_to be_nil

  disciplina = Disciplina.find_by(name: nome_disciplina)
  turma = disciplina.turmas.first
  expect(turma.usuarios).to include(usuario)
end

Então('eu devo ver os detalhes do erro {string}') do |error_detail|
  json_response = JSON.parse(last_response.body)
  expect(json_response.to_s).to include(error_detail)
end