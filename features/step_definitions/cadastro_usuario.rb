# --- DADO (Setup dos Cenários) ---

Dado('que o usuário {string} NÃO existe no sistema') do |email|
  # Garante que não existe um usuário com este e-mail antes do teste
  Usuario.find_by(email: email)&.destroy
end

Dado('que o usuário {string} JÁ existe no sistema') do |email|
  # Garante que o usuário já existe no banco de dados de teste
  FactoryBot.create(:usuario, email: email)
end

Dado('que a turma com código {string} NÃO existe no sistema') do |codigo_turma|
  # Garante que não existe uma turma com este código
  Turma.find_by(class_code: codigo_turma)&.destroy
end


# --- QUANDO (Ação Principal) ---

Quando('o administrador importa um arquivo de alunos para a turma {string} contendo os dados de {string}') do |nome_turma, email_aluno|
  raise "A variável @turma não foi definida no passo 'Dado'. Verifique o seu teste." unless @turma

  # Usa a @turma e a @disciplina que foram criadas no passo 'Dado'
  dados_json = [{
    # --- A LINHA CORRIGIDA ESTÁ AQUI ---
    "code" => @disciplina.codigo, # Trocado de .code para .codigo
    "classCode" => @turma.codigo_turma, # Verifique se este é o nome correto da coluna na tabela turmas
    "semester" => @turma.semestre,
    "dicente" => [{ "nome" => "Aluno Teste", "matricula" => "123456", "email" => email_aluno }]
  }]
  
  arquivo_simulado = double(read: dados_json.to_json)
  
  # Executa o serviço de importação
  @resultado_importacao = AlunoImporterService.new(arquivo_simulado).call
end

Quando('o administrador importa um arquivo de alunos com um e-mail inválido') do
  dados_json = [{
    "code" => @turma.disciplina.code,
    "classCode" => @turma.class_code,
    "semester" => @turma.semester,
    "dicente" => [{ "nome" => "Aluno Invalido", "matricula" => "654321", "email" => "email-invalido" }] # E-mail inválido
  }]
  
  arquivo_simulado = double(read: dados_json.to_json)
  @resultado_importacao = AlunoImporterService.new(arquivo_simulado).call
end

Quando('o administrador importa um arquivo de alunos para a turma {string}') do |codigo_turma_invalida|
  dados_json = [{
    "code" => "CODIGO_FALSO",
    "classCode" => codigo_turma_invalida,
    "semester" => "2025.1",
    "dicente" => [{ "nome" => "Aluno Teste", "matricula" => "123456", "email" => "aluno.teste@email.com" }]
  }]
  
  arquivo_simulado = double(read: dados_json.to_json)
  @resultado_importacao = AlunoImporterService.new(arquivo_simulado).call
end


# --- ENTÃO (Verificação dos Resultados) ---

Então('o usuário {string} deve ser criado no sistema') do |email|
  # Verifica se o usuário agora existe no banco de dados
  expect(Usuario.find_by(email: email)).to be_present
end

Então('um e-mail de definição de senha deve ser enviado para {string}') do |email|
  # Verifica se um e-mail foi adicionado à fila de entrega
  # e se o destinatário é o correto.
  expect(ActionMailer::Base.deliveries.size).to eq(1)
  expect(ActionMailer::Base.deliveries.last.to).to include(email)
end

Então('um e-mail de definição de senha NÃO deve ser enviado para {string}') do |email|
  # Verifica se a fila de entrega de e-mails está vazia
  expect(ActionMailer::Base.deliveries).to be_empty
end

Então('nenhum usuário novo deve ser criado') do
  # Verifica se a contagem total de usuários não mudou
  expect { @resultado_importacao }.not_to change(Usuario, :count)
end

Então('nenhum e-mail de definição de senha deve ser enviado') do
  expect(ActionMailer::Base.deliveries).to be_empty
end