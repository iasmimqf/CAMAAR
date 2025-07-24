# --- DADO (Setup) ---

Dado('que a disciplina {string} com código {string} já existe') do |nome_disciplina, codigo_disciplina|
  @disciplina = FactoryBot.create(:disciplina, nome: nome_disciplina, codigo: codigo_disciplina) # Você precisará de uma factory para :disciplina
  @turma = FactoryBot.create(:turma, disciplina: @disciplina, codigo_turma: 'TA', semestre: '2021.2')
end

# --- ENTÃO (Verificação do Resultado da API) ---

Então('eu devo ver a mensagem de erro {string}') do |mensagem|
  expect(last_response.status).to eq(422) # Unprocessable Entity

  json_response = JSON.parse(last_response.body)
  expect(json_response['errors'].first).to include(mensagem)
end

Então('eu devo ver a mensagem {string}') do |mensagem|
  # Verificamos a resposta da API, não a página
  expect(last_response.status).to be_in([ 200, 422 ]) # Sucesso ou Erro de Validação

  json_response = JSON.parse(last_response.body)

  # A mensagem pode estar na chave 'message' (sucesso) ou 'errors' (falha)
  response_message = json_response['message'] || json_response['errors'].first
  expect(response_message).to include(mensagem)
end
