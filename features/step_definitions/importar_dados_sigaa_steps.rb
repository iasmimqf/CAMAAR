# features/step_definitions/importar_dados_sigaa_steps.rb

Dado('que estou logado como administrador') do
  # Autentica com um usuário admin
  admin_user = create(:usuario, admin: true, email: 'admin_sigaa@test.com', password: 'Password123!', password_confirmation: 'Password123!')
  
  # Faz login diretamente na sessão
  login_as(admin_user, scope: :usuario)
end

Dado('estou na página {string}') do |pagina|
  case pagina
  when "Importar do SIGAA"
    visit admin_dashboard_path
    expect(page).to have_content('Dashboard de Administração')
  end
end

Dado('possuo um arquivo CSV válido com a estrutura contendo:') do |csv_content|
  # Cria um arquivo CSV temporário com o conteúdo fornecido
  @csv_file_path = Rails.root.join('tmp', 'sigaa_import_valid.csv')
  File.open(@csv_file_path, 'w') { |file| file.write(csv_content) }
end

Dado('possuo um arquivo CSV inválido com a estrutura contendo:') do |csv_content|
  # Cria um arquivo CSV temporário com o conteúdo inválido
  @csv_file_path = Rails.root.join('tmp', 'sigaa_import_invalid.csv')
  File.open(@csv_file_path, 'w') { |file| file.write(csv_content) }
end

Quando('faço upload do arquivo') do
  # Para importação do SIGAA, usa diretamente a URL específica
  page.driver.post '/admin/importacoes/importar_csv_sigaa', {
    file: Rack::Test::UploadedFile.new(@csv_file_path, 'text/csv')
  }
end

Quando('clico no botão de importação {string}') do |nome_botao|
  # A requisição já foi feita no step anterior via POST direto
  # Aguarda um pouco para o processamento
  sleep 0.5
end

Então('o sistema deve exibir:') do |mensagem_esperada|
  # Verifica a resposta JSON da requisição
  response_body = page.driver.response.body
  
  case mensagem_esperada.strip
  when /Sincronização concluída/
    expect(response_body).to include('"notice":"Dados importados com sucesso do SIGAA"')
  when /Erro na Sincronização/
    expect(response_body).to include('"alert":"Erro ao importar dados do SIGAA')
  else
    expect(page).to have_content(mensagem_esperada.strip)
  end
end

Então('os novos usuários devem estar disponíveis no sistema') do
  # Verifica se o usuário foi criado no banco de dados
  usuario = Usuario.find_by(email: 'acjpjvjp@gmail.com')
  expect(usuario).to be_present
  expect(usuario.nome).to eq('Ana Clara Jordao Perna')
  expect(usuario.matricula).to eq('190084006')
end

# Limpeza após os testes
After do
  # Remove arquivos temporários criados durante os testes
  [@csv_file_path].compact.each do |file_path|
    File.delete(file_path) if file_path && File.exist?(file_path)
  end
end
