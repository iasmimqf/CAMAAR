# Caminho: features/step_definitions/importacao_steps.rb
require 'jwt' # Garante que a biblioteca JWT seja carregada

# --- DADO (Setup do Cenário) ---

##
# Dado: Que eu estou autenticado como um tipo de usuário.
#
# Descrição: Cria um usuário de teste (administrador por padrão neste step)
#    com uma senha conhecida e simula um login real na API para obter um token JWT.
#    Este token é então armazenado para ser usado em requisições autenticadas subsequentes.
# Argumentos:
#    - `tipo_usuario` (String): O tipo de usuário a ser autenticado (e.g., "administrador").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Usuario` no banco de dados.
#    - Realiza uma requisição POST para o endpoint de login.
#    - Define a variável de instância `@user` com o usuário criado.
#    - Define a variável de instância `@auth_headers` com o token de autorização.
#    - Pode levantar uma exceção se a autenticação falhar.
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

##
# Quando: Envio um arquivo para o endpoint de importação de turmas.
#
# Descrição: Carrega um arquivo de teste do sistema de arquivos e o envia
#    como parte de uma requisição POST para o endpoint de importação de turmas
#    (`admin/importacoes/importar_turmas`). A requisição é autenticada usando
#    o token JWT obtido anteriormente.
# Argumentos:
#    - `filename` (String): O nome do arquivo a ser enviado (e.g., "turmas.json").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Envia uma requisição HTTP POST autenticada para a aplicação.
#    - Popula a variável global `last_response` com a resposta da requisição.
#    - Pode iniciar um processo de importação de dados de turmas no backend.
Quando('eu envio o arquivo {string} para o endpoint de importação de turmas') do |filename|
  file_path = Rails.root.join('features', 'support', 'test_files', filename)
  file = Rack::Test::UploadedFile.new(file_path, 'application/json')

  # Usa o token capturado para fazer a requisição autenticada
  post '/admin/importacoes/importar_turmas', params: { file: file }, headers: @auth_headers
end

##
# Quando: Envio um arquivo para o endpoint de importação de alunos.
#
# Descrição: Carrega um arquivo de teste do sistema de arquivos e o envia
#    como parte de uma requisição POST para o endpoint de importação de alunos
#    (`admin/importacoes/importar_alunos`). A requisição é autenticada usando
#    o token JWT obtido anteriormente.
# Argumentos:
#    - `filename` (String): O nome do arquivo a ser enviado (e.g., "alunos.json").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Envia uma requisição HTTP POST autenticada para a aplicação.
#    - Popula a variável global `last_response` com a resposta da requisição.
#    - Pode iniciar um processo de importação de dados de alunos e docentes no backend.
Quando('eu envio o arquivo {string} para o endpoint de importação de alunos') do |filename|
  file_path = Rails.root.join('features', 'support', 'test_files', filename)
  file = Rack::Test::UploadedFile.new(file_path, 'application/json')

  # Usa o token capturado para fazer a requisição autenticada
  post '/admin/importacoes/importar_alunos', params: { file: file }, headers: @auth_headers
end


# --- ENTÃO (Verificação da Resposta da API) ---

##
# Então: A resposta da API deve ser de sucesso.
#
# Descrição: Verifica se o status HTTP da última resposta da API é 200 (OK) ou 201 (Created),
#    indicando que a operação foi bem-sucedida. Inclui uma mensagem de depuração
#    se o status não for de sucesso.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Pode imprimir mensagens de depuração no console em caso de falha.
#    - Levanta exceções se a expectativa não for atendida.
Então('a resposta da API deve ser de sucesso') do
  # Adiciona um puts de depuração em caso de falha para vermos a resposta
  puts "DEBUG: Resposta da API com falha: #{last_response.body}" unless [ 200, 201 ].include?(last_response.status)

  expect(last_response.status).to be_in([ 200, 201 ]) # OK ou Created
end

##
# Então: A resposta da API deve ser um erro com a mensagem especificada.
#
# Descrição: Verifica se o status HTTP da última resposta da API é 400 (Bad Request)
#    ou 422 (Unprocessable Entity), e se o JSON da resposta contém a mensagem de erro esperada.
# Argumentos:
#    - `message` (String): A mensagem de erro esperada na resposta da API.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('a resposta da API deve ser um erro com a mensagem {string}') do |message|
  expect(last_response.status).to be_in([ 400, 422 ]) # Bad Request ou Unprocessable Entity

  json_response = JSON.parse(last_response.body)
  response_message = json_response['alert'] || json_response['errors']&.first
  expect(response_message).to include(message)
end

##
# Então: A turma deve ser criada no sistema.
#
# Descrição: Verifica se uma disciplina com o nome fornecido existe e se ela
#    possui turmas associadas, confirmando a criação da turma no sistema.
# Argumentos:
#    - `nome_disciplina` (String): O nome da disciplina à qual a turma pertence.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('a turma {string} deve ser criada no sistema.') do |nome_disciplina|
  disciplina = Disciplina.find_by(nome: nome_disciplina) # Correção: usar `nome` em vez de `name`
  expect(disciplina).not_to be_nil
  expect(disciplina.turmas).not_to be_empty
end

##
# Então: O usuário deve ser criado e associado à turma.
#
# Descrição: Verifica se um usuário com o nome completo fornecido existe e se
#    ele está associado à turma da disciplina especificada.
# Argumentos:
#    - `nome_usuario` (String): O nome completo do usuário.
#    - `nome_disciplina` (String): O nome da disciplina da turma.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('o usuário {string} deve ser criado e associado à turma {string}.') do |nome_usuario, nome_disciplina|
  usuario = Usuario.find_by(nome: nome_usuario) # Correção: usar `nome` em vez de `nome_completo`
  expect(usuario).not_to be_nil

  disciplina = Disciplina.find_by(nome: nome_disciplina) # Correção: usar `nome` em vez de `name`
  turma = disciplina.turmas.first
  expect(turma.usuarios).to include(usuario)
end

##
# Então: Eu devo ver os detalhes do erro.
#
# Descrição: Verifica se a resposta JSON da API contém um detalhe de erro específico.
# Argumentos:
#    - `error_detail` (String): O detalhe do erro esperado na resposta JSON.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('eu devo ver os detalhes do erro {string}') do |error_detail|
  json_response = JSON.parse(last_response.body)
  expect(json_response.to_s).to include(error_detail)
end
