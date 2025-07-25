# Caminho: features/step_definitions/sincronizacao_steps.rb

# --- DADO ---

##
# Dado: Que eu sou um administrador logado e estou na página de Gerenciamento.
#
# Descrição: Cria um usuário com privilégios de administrador e o autentica
#    programaticamente usando `login_as`. Em seguida, navega para a página
#    principal do dashboard administrativo.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Usuario` (administrador) no banco de dados.
#    - Autentica o usuário na sessão de teste.
#    - Altera a página atual do navegador simulado para o dashboard administrativo.
Dado('que eu sou um administrador logado e estou na página de Gerenciamento') do
  admin = create(:usuario, :admin)
  # login_as é um helper de teste do Devise/Warden.
  # Garante que o usuário está logado para esta sessão de teste.
  login_as(admin, scope: :usuario)
  # Visita a página principal do admin.
  visit '/admin/dashboard' # ou a rota correta (ex: admin_dashboard_path)
end

##
# Dado: Que a disciplina com nome e código especificados já existe.
#
# Descrição: Cria um registro de `Disciplina` com o nome e código fornecidos.
#    Em seguida, cria uma turma de exemplo associada a esta disciplina.
# Argumentos:
#    - `nome_disciplina` (String): O nome da disciplina.
#    - `codigo_disciplina` (String): O código da disciplina.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais:
#    - Cria um registro de `Disciplina` no banco de dados.
#    - Cria um registro de `Turma` associado à disciplina.
Dado('que a disciplina {string} com código {string} já existe') do |nome_disciplina, codigo_disciplina|
  disciplina = create(:disciplina, nome: nome_disciplina, codigo: codigo_disciplina) # Você precisará de uma factory para :disciplina
  create(:turma, disciplina: disciplina, codigo_turma: 'TA', semestre: '2021.2')
end


# --- QUANDO ---

##
# Quando: Eu clico no botão.
#
# Descrição: Simula o clique em um botão na página, identificado pelo seu nome.
# Argumentos:
#    - `nome_botao` (String): O texto visível do botão a ser clicado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Dispara a ação associada ao botão clicado.
Quando('eu clico no botão {string}') do |nome_botao|
  click_button nome_botao
end

##
# Quando: O modal de importação aparece.
#
# Descrição: Verifica se um elemento HTML com o ID 'import-modal' está visível
#    na página, confirmando que o modal de importação foi exibido.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se o modal não estiver visível.
Quando('o modal de importação aparece') do
  # Este passo verifica se um elemento com o id 'import-modal' está visível.
  # Vamos criar este elemento no nosso HTML.
  expect(page).to have_selector('#import-modal', visible: true)
end

##
# Quando: Eu clico no botão dentro do modal.
#
# Descrição: Espera que o modal de importação esteja visível e, em seguida,
#    procura e clica em um botão ou link específico dentro desse modal.
# Argumentos:
#    - `nome_botao` (String): O texto visível do botão ou link a ser clicado dentro do modal.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Dispara a ação associada ao elemento clicado dentro do modal.
#    - Levanta exceções se o modal não aparecer ou se o elemento não for encontrado.
Quando('eu clico no botão {string} dentro do modal') do |nome_botao|
  # Espera o modal aparecer
  expect(page).to have_css('#import-modal', visible: true)

  # Dentro do modal, clica no botão
  within('#import-modal') do
    # Tenta encontrar tanto link quanto button
    if page.has_link?(nome_botao)
      click_link nome_botao
    elsif page.has_button?(nome_botao)
      click_button nome_botao
    else
      raise "Elemento #{nome_botao} não encontrado no modal"
    end
  end
end

##
# Quando: Eu anexo um arquivo a um campo de upload.
#
# Descrição: Anexa um arquivo de teste (localizado em `features/support/`)
#    a um campo de upload de arquivo no formulário, identificado pelo seu nome.
# Argumentos:
#    - `nome_arquivo` (String): O nome do arquivo de teste a ser anexado.
#    - `nome_campo` (String): O nome do campo de upload (e.g., "file").
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Preenche o campo de upload de arquivo na página.
Quando('eu anexo o arquivo {string} ao campo {string}') do |nome_arquivo, nome_campo|
  # Anexa um arquivo de teste (que deve estar em features/support/) ao campo de upload.
  attach_file(nome_campo, Rails.root.join('features', 'support', nome_arquivo))
end


# --- ENTÃO ---

##
# Então: Eu devo ver a mensagem.
#
# Descrição: Verifica a presença de uma mensagem específica na página,
#    confirmando o resultado de uma operação.
# Argumentos:
#    - `mensagem` (String): O texto da mensagem esperada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('eu devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

##
# Então: A turma deve ser criada no sistema.
#
# Descrição: Verifica se a disciplina e a turma associada foram criadas
#    corretamente no banco de dados, usando os nomes e códigos esperados.
# Argumentos:
#    - `nome_disciplina` (String): O nome da disciplina.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('a turma de {string} deve ser criada no sistema.') do |nome_disciplina|
  # 1. First, find the discipline by name.
  disciplina = Disciplina.find_by(nome: nome_disciplina)

  # 2. Assert that the discipline was found (or created).
  expect(disciplina).not_to be_nil, "A disciplina '#{nome_disciplina}' não foi encontrada."

  # 3. Then, find the class associated with that discipline.
  turma = disciplina.turmas.find_by(codigo_turma: 'TA')

  # 4. Assert that the class was found (or created).
  expect(turma).not_to be_nil, "A turma 'TA' para a disciplina '#{nome_disciplina}' não foi encontrada."
end

##
# Então: O usuário deve ser criado e associado à turma.
#
# Descrição: Verifica se um usuário com o nome completo fornecido foi criado
#    e se ele está corretamente associado à turma especificada.
# Argumentos:
#    - `nome_usuario` (String): O nome completo do usuário.
#    - `nome_turma` (String): O nome da turma à qual o usuário deve estar associado.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se as expectativas não forem atendidas.
Então('o usuário {string} deve ser criado e associado à turma {string}.') do |nome_usuario, nome_turma|
  # 1. Find the user and the class in the database.
  usuario = Usuario.find_by(nome: nome_usuario) # Correção: usar `nome` em vez de `nome_completo`
  turma = Turma.find_by(nome_completo: nome_turma) # Correção: usar `nome_completo` se for o nome da turma

  # 2. Check that both were actually found.
  expect(usuario).not_to be_nil
  expect(turma).not_to be_nil

  # 3. Check that the user is included in the class's list of users.
  # This verifies the many-to-many association.
  expect(turma.usuarios).to include(usuario)
end

##
# Então: O modal de importação deve ser fechado.
#
# Descrição: Verifica se o elemento HTML com o ID 'import-modal' não está
#    mais visível na página, confirmando que o modal de importação foi fechado.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se o modal ainda estiver visível.
Então('o modal de importação deve ser fechado') do
  # This step checks that the element with the ID 'import-modal' is NOT visible.
  # The 'visible: :hidden' option tells Capybara to assert that the element
  # might exist in the HTML but is not visible to the user (e.g., display: none).
  expect(page).to have_selector('#import-modal', visible: :hidden)
end

##
# Então: Eu devo permanecer na página de Gerenciamento.
#
# Descrição: Verifica se a URL atual do navegador simulado ainda corresponde
#    ao caminho do dashboard administrativo, confirmando que não houve
#    redirecionamento para outra página.
# Argumentos: Nenhum.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a URL atual não corresponder ao esperado.
Então('eu devo permanecer na página de Gerenciamento.') do
  # This checks that the current URL is still the admin dashboard path.
  # This confirms no redirection happened.
  expect(page).to have_current_path(admin_dashboard_path)
end

##
# Então: Eu devo ver a mensagem de erro.
#
# Descrição: Verifica a presença de uma mensagem de erro específica na página.
# Argumentos:
#    - `mensagem_de_erro` (String): O texto da mensagem de erro esperada.
# Retorno: Nenhum valor explícito.
# Efeitos colaterais: Nenhum.
#    - Levanta exceções se a expectativa não for atendida.
Então('eu devo ver a mensagem de erro {string}') do |mensagem_de_erro|
  # This reuses a step we already have to check for text on the page.
  expect(page).to have_content(mensagem_de_erro)
end
