# Caminho: features/step_definitions/cadastro_usuario.rb

# --- DADO (Setup dos Cenários) ---

##
# Garante que um usuário com o e-mail especificado NÃO existe no sistema.
#
# Descrição: Antes de iniciar um cenário de teste, este passo remove qualquer
#    registro de usuário existente com o e-mail fornecido, assegurando um
#    estado limpo para o teste.
# Argumentos:
#    - `email` (String): O endereço de e-mail do usuário a ser verificado/removido.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Pode destruir um registro de `Usuario` no banco de dados.
Dado('que o usuário {string} NÃO existe no sistema') do |email|
  # Garante que não existe um usuário com este e-mail antes do teste
  Usuario.find_by(email: email)&.destroy
end

##
# Garante que um usuário com o e-mail especificado JÁ existe no sistema.
#
# Descrição: Antes de iniciar um cenário de teste, este passo cria um usuário
#    com o e-mail fornecido usando FactoryBot, garantindo que ele esteja presente
#    no banco de dados para o teste.
# Argumentos:
#    - `email` (String): O endereço de e-mail do usuário a ser criado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Cria um registro de `Usuario` no banco de dados.
Dado('que o usuário {string} JÁ existe no sistema') do |email|
  # Garante que o usuário já existe no banco de dados de teste
  FactoryBot.create(:usuario, email: email)
end

##
# Garante que a turma com o código especificado NÃO existe no sistema.
#
# Descrição: Antes de iniciar um cenário de teste, este passo remove qualquer
#    registro de turma existente com o código fornecido, assegurando um
#    estado limpo para o teste.
# Argumentos:
#    - `codigo_turma` (String): O código da turma a ser verificada/removida.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Pode destruir um registro de `Turma` no banco de dados.
Dado('que a turma com código {string} NÃO existe no sistema') do |codigo_turma|
  # Garante que não existe uma turma com este código
  Turma.find_by(codigo_turma: codigo_turma)&.destroy
end


# --- QUANDO (Ação Principal) ---

##
# O administrador importa um arquivo de alunos para uma turma específica.
#
# Descrição: Simula o processo de importação de dados de alunos para uma turma
#    existente. Constrói um JSON com informações da disciplina, turma e discente,
#    cria um arquivo simulado e executa o `AlunoImporterService`.
# Argumentos:
#    - `nome_turma` (String): O nome da turma (usado para contexto).
#    - `email_aluno` (String): O e-mail do aluno a ser importado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Define a variável de instância `@resultado_importacao` com o resultado do serviço.
#    - Pode criar/atualizar registros de `Usuario` e associá-los a `Turma`.
Quando('o administrador importa um arquivo de alunos para a turma {string} contendo os dados de {string}') do |nome_turma, email_aluno|
  raise "A variável @turma não foi definida no passo 'Dado'. Verifique o seu teste." unless @turma

  # Usa a @turma e a @disciplina que foram criadas no passo 'Dado'
  dados_json = [ {
    # --- A LINHA CORRIGIDA ESTÁ AQUI ---
    "code" => @disciplina.codigo, # Trocado de .code para .codigo
    "classCode" => @turma.codigo_turma, # Verifique se este é o nome correto da coluna na tabela turmas
    "semester" => @turma.semestre,
    "dicente" => [ { "nome" => "Aluno Teste", "matricula" => "123456", "email" => email_aluno } ]
  } ]

  arquivo_simulado = double(read: dados_json.to_json)

  # Executa o serviço de importação
  @resultado_importacao = AlunoImporterService.new(arquivo_simulado).call
end

##
# O administrador importa um arquivo de alunos com um e-mail inválido.
#
# Descrição: Simula uma tentativa de importação onde os dados do aluno
#    contêm um endereço de e-mail em formato inválido, testando a validação.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Define a variável de instância `@resultado_importacao` com o resultado do serviço,
#      que deve incluir erros de validação.
Quando('o administrador importa um arquivo de alunos com um e-mail inválido') do
  dados_json = [ {
    "code" => @turma.disciplina.codigo, # Usando .codigo da disciplina
    "classCode" => @turma.codigo_turma,
    "semester" => @turma.semestre,
    "dicente" => [ { "nome" => "Aluno Invalido", "matricula" => "654321", "email" => "email-invalido" } ] # E-mail inválido
  } ]

  arquivo_simulado = double(read: dados_json.to_json)
  @resultado_importacao = AlunoImporterService.new(arquivo_simulado).call
end

##
# O administrador importa um arquivo de alunos para uma turma inexistente.
#
# Descrição: Simula uma tentativa de importação onde a turma referenciada
#    nos dados JSON não existe no sistema, testando o tratamento de erros.
# Argumentos:
#    - `codigo_turma_invalida` (String): O código de uma turma que não existe.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Define a variável de instância `@resultado_importacao` com o resultado do serviço,
#      que deve incluir erros de "turma não encontrada".
Quando('o administrador importa um arquivo de alunos para a turma {string}') do |codigo_turma_invalida|
  dados_json = [ {
    "code" => "CODIGO_FALSO", # Pode ser um código de disciplina que não existe
    "classCode" => codigo_turma_invalida,
    "semester" => "2025.1",
    "dicente" => [ { "nome" => "Aluno Teste", "matricula" => "123456", "email" => "aluno.teste@email.com" } ]
  } ]

  arquivo_simulado = double(read: dados_json.to_json)
  @resultado_importacao = AlunoImporterService.new(arquivo_simulado).call
end


# --- ENTÃO (Verificação dos Resultados) ---

##
# O usuário deve ser criado no sistema.
#
# Descrição: Verifica se um registro de `Usuario` com o e-mail fornecido
#    agora existe no banco de dados, confirmando o sucesso da criação do usuário.
# Argumentos:
#    - `email` (String): O endereço de e-mail do usuário que se espera ter sido criado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida, indicando falha no teste.
Então('o usuário {string} deve ser criado no sistema') do |email|
  # Verifica se o usuário agora existe no banco de dados
  expect(Usuario.find_by(email: email)).to be_present
end

##
# Um e-mail de definição de senha deve ser enviado para o endereço especificado.
#
# Descrição: Verifica se exatamente um e-mail foi adicionado à fila de entrega
#    do Action Mailer e se o destinatário desse e-mail é o endereço fornecido.
# Argumentos:
#    - `email` (String): O endereço de e-mail para o qual se espera que o e-mail tenha sido enviado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida, indicando falha no teste.
Então('um e-mail de definição de senha deve ser enviado para {string}') do |email|
  # Verifica se um e-mail foi adicionado à fila de entrega
  # e se o destinatário é o correto.
  expect(ActionMailer::Base.deliveries.size).to eq(1)
  expect(ActionMailer::Base.deliveries.last.to).to include(email)
end

##
# Um e-mail de definição de senha NÃO deve ser enviado para o endereço especificado.
#
# Descrição: Verifica se a fila de entrega de e-mails do Action Mailer está vazia,
#    confirmando que nenhum e-mail de redefinição de senha foi enviado.
# Argumentos:
#    - `email` (String): O endereço de e-mail para o qual se espera que nenhum e-mail tenha sido enviado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida, indicando falha no teste.
Então('um e-mail de definição de senha NÃO deve ser enviado para {string}') do |email|
  # Verifica se a fila de entrega de e-mails está vazia
  expect(ActionMailer::Base.deliveries).to be_empty
end

##
# Nenhum usuário novo deve ser criado.
#
# Descrição: Verifica se a contagem total de usuários no banco de dados
#    não foi alterada após a execução da importação.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida, indicando falha no teste.
Então('nenhum usuário novo deve ser criado') do
  # Verifica se a contagem total de usuários não mudou
  expect { @resultado_importacao }.not_to change(Usuario, :count)
end

##
# Nenhum e-mail de definição de senha deve ser enviado.
#
# Descrição: Verifica se a fila de entrega de e-mails do Action Mailer está vazia,
#    confirmando que nenhuma instrução de redefinição de senha foi despachada.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida, indicando falha no teste.
Então('nenhum e-mail de definição de senha deve ser enviado') do
  expect(ActionMailer::Base.deliveries).to be_empty
end
