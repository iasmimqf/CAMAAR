Dado('que eu sou um administrador logado e estou na página de Gerenciamento') do
  admin = create(:usuario, :admin)
  # login_as é um helper de teste do Devise/Warden.
  # Garante que o usuário está logado para esta sessão de teste.
  login_as(admin, scope: :usuario)
  # Visita a página principal do admin.
  visit '/admin/dashboard' # ou a rota correta (ex: admin_dashboard_path)
end

Dado('que a disciplina {string} com código {string} já existe') do |nome_disciplina, codigo_disciplina|
  disciplina = create(:disciplina, nome: nome_disciplina, codigo: codigo_disciplina) # Você precisará de uma factory para :disciplina
  create(:turma, disciplina: disciplina, codigo_turma: 'TA', semestre: '2021.2')
end


Quando('eu clico no botão {string}') do |nome_botao|
  click_button nome_botao
end

Quando('o modal de importação aparece') do
  # Este passo verifica se um elemento com o id 'import-modal' está visível.
  # Vamos criar este elemento no nosso HTML.
  expect(page).to have_selector('#import-modal', visible: true)
end

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

Quando('eu anexo o arquivo {string} ao campo {string}') do  |nome_arquivo, nome_campo|
  # Anexa um arquivo de teste (que deve estar em features/support/) ao campo de upload.
  attach_file(nome_campo, Rails.root.join('import_files', nome_arquivo))
end


Então('eu devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

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

Então('o usuário {string} deve ser criado e associado à turma {string} de {string} do semestre {string}.') do |nome_usuario, codigo_turma, nome_disciplina, semestre|
  # 1. Find the user and the class in the database.
  usuario = Usuario.find_by(nome: nome_usuario)
  disciplina = Disciplina.find_by(nome: nome_disciplina)
  turma = disciplina.turmas.find_by(codigo_turma: codigo_turma, semestre: semestre)

  # 2. Check that both were actually found.
  expect(usuario).not_to be_nil
  expect(turma).not_to be_nil

  # 3. Check that the user is included in the class's list of users.
  # This verifies the many-to-many association.
  expect(turma.usuarios).to include(usuario)
end

Então('o modal de importação deve ser fechado') do
  expect(page).to have_no_selector('#import-modal[data-controller="modal"]:not(.hidden)', visible: true, wait: 5)
end

Então('eu devo permanecer na página de Gerenciamento.') do
  # This checks that the current URL is still the admin dashboard path.
  # This confirms no redirection happened.
  expect(page).to have_current_path(admin_dashboard_path)
end

Então('eu devo ver a mensagem de erro {string}') do |mensagem_de_erro|
  # This reuses a step we already have to check for text on the page.
  expect(page).to have_content(mensagem_de_erro)
end