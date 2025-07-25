# Caminho: features/step_definitions/web_steps.rb

# --- DADO (Setup) ---

##
# Dado: Que a disciplina com nome e código especificados já existe.
#
# Descrição: Cria um registro de `Disciplina` com o nome e código fornecidos.
#    Em seguida, cria uma turma de exemplo associada a esta disciplina.
# Argumentos:
#    - `nome_disciplina` (String): O nome da disciplina a ser criada.
#    - `codigo_disciplina` (String): O código da disciplina a ser criada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Disciplina` no banco de dados.
#    - Cria um registro de `Turma` associado à disciplina.
#    - Define as variáveis de instância `@disciplina` e `@turma`.
Dado('que a disciplina {string} com código {string} já existe') do |nome_disciplina, codigo_disciplina|
  @disciplina = FactoryBot.create(:disciplina, nome: nome_disciplina, codigo: codigo_disciplina) # Você precisará de uma factory para :disciplina
  @turma = FactoryBot.create(:turma, disciplina: @disciplina, codigo_turma: 'TA', semestre: '2021.2')
end

# --- ENTÃO (Verificação do Resultado da API) ---

##
# Então: Eu devo ver a mensagem de erro.
#
# Descrição: Verifica se o status da última resposta da API é 422 (Unprocessable Entity)
#    e se o corpo da resposta JSON contém a mensagem de erro esperada.
# Argumentos:
#    - `mensagem` (String): A mensagem de erro esperada na resposta.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('eu devo ver a mensagem de erro {string}') do |mensagem|
  expect(last_response.status).to eq(422) # Unprocessable Entity

  json_response = JSON.parse(last_response.body)
  expect(json_response['errors'].first).to include(mensagem)
end

##
# Então: Eu devo ver a mensagem.
#
# Descrição: Verifica se o status da última resposta da API é 200 (OK) ou 422 (Unprocessable Entity)
#    e se o corpo da resposta JSON contém a mensagem esperada, que pode ser de sucesso ou erro.
# Argumentos:
#    - `mensagem` (String): A mensagem esperada na resposta.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('eu devo ver a mensagem {string}') do |mensagem|
  # Verificamos a resposta da API, não a página
  expect(last_response.status).to be_in([ 200, 422 ]) # Sucesso ou Erro de Validação

  json_response = JSON.parse(last_response.body)

  # A mensagem pode estar na chave 'message' (sucesso) ou 'errors' (falha)
  response_message = json_response['message'] || json_response['errors'].first
  expect(response_message).to include(mensagem)
end
