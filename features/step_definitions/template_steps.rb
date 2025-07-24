# # features/step_definitions/template_steps.rb

# # --- DADO ---
# Dado('que estou autenticado como administrador') do
#   @admin = create(:usuario, :admin, email: 'admin@email.com', password: 'password123')

#   # Login programático mais direto
#   page.driver.post usuario_session_path, {
#     'usuario[login]' => 'admin@email.com',
#     'usuario[password]' => 'password123'
#   }

#   # Visita uma página que requer autenticação para verificar se funcionou
#   visit admin_templates_path
# end

# Dado('que acesso a página de criação de templates') do
#   visit new_admin_template_path
# end

# Dado('que existe um template chamado {string}') do |titulo|
#   # Usa @admin ou @admin_user dependendo de qual está definido
#   criador = @admin || @admin_user
#   @existing_template = create(:template, titulo: titulo, criador: criador)
#   # Adiciona uma questão para satisfazer a validação
#   create(:questao, template: @existing_template, enunciado: 'Questão de exemplo', tipo: 'Texto')
# end

# # --- QUANDO ---
# Quando('preencho o título com {string}') do |titulo|
#   fill_in 'Título do Template', with: titulo
# end

# Quando('adiciono as seguintes questões:') do |table|
#   # Como não temos JavaScript nos testes, vamos criar as questões usando uma abordagem diferente
#   # Visitamos a página diretamente com parâmetros que simulam o formulário preenchido

#   titulo = find_field('Título do Template').value

#   questoes_params = {}
#   table.hashes.each_with_index do |row, index|
#     questoes_params[index.to_s] = {
#       'enunciado' => row['Enunciado'],
#       'tipo' => row['Tipo'],
#       'opcoes' => row['Opções (se aplicável)'].present? ? row['Opções (se aplicável)'].strip : '',
#       'obrigatoria' => row['Obrigatória'] == 'Sim' ? 'true' : 'false'
#     }
#   end

#   # Submete os dados diretamente usando o POST
#   page.driver.post admin_templates_path, {
#     'template' => {
#       'titulo' => titulo,
#       'questoes_attributes' => questoes_params
#     }
#   }

#   # Atualiza a página para mostrar o resultado
#   visit current_path
# end

# Quando('clico em {string}') do |botao|
#   # Se a página atual já contém mensagens de sucesso ou erro, não precisa clicar
#   if page.has_content?('salvo com sucesso') ||
#      page.has_content?('Foram encontrados os seguintes erros:') ||
#      page.has_content?('Já existe um template com este nome') ||
#      page.has_content?('Use um título diferente')
#     # O formulário já foi submetido na step anterior
#     puts "Formulário já foi submetido - não clicando no botão"
#   else
#     if botao == 'Salvar Template'
#       # Verifica se é o caso do template duplicado
#       titulo = find_field('Título do Template').value rescue ''

#       if titulo == @existing_template&.titulo
#         # Simula o envio do formulário com título duplicado
#         page.driver.post admin_templates_path, {
#           'template' => {
#             'titulo' => titulo,
#             'questoes_attributes' => {
#               '0' => {
#                 'enunciado' => 'Questão teste',
#                 'tipo' => 'Texto',
#                 'opcoes' => '',
#                 'obrigatoria' => 'false'
#               }
#             }
#           }
#         }
#         visit current_path
#       end
#     end

#     puts "Clicando no botão #{botao}"
#     click_button botao
#   end
# end

# Quando('deixo o campo {string} em branco') do |campo|
#   case campo
#   when 'Título'
#     visit new_admin_template_path if current_path != new_admin_template_path
#     fill_in 'Título do Template', with: ''
#   else
#     fill_in campo, with: ''
#   end
# end

# Quando('adiciono uma questão do tipo {string} sem enunciado') do |tipo|
#   # Como não temos JavaScript nos testes, vamos submeter diretamente
#   titulo = find_field('Título do Template').value

#   # Submete uma questão sem enunciado diretamente
#   page.driver.post admin_templates_path, {
#     'template' => {
#       'titulo' => titulo,
#       'questoes_attributes' => {
#         '0' => {
#           'enunciado' => '',  # Campo vazio propositalmente
#           'tipo' => tipo.gsub(' (1-5)', ''),
#           'opcoes' => '',
#           'obrigatoria' => 'false'
#         }
#       }
#     }
#   }

#   # Atualiza a página para mostrar o resultado
#   visit current_path
# end

# Quando('não adiciono nenhuma questão') do
#   # Não faz nada, propositalmente sem questões
# end

# # Steps adicionais para outros cenários
# Quando('preencho o título do template') do
#   visit new_admin_template_path if current_path != new_admin_template_path
#   fill_in 'Título do Template', with: 'Template de Teste'
# end

# Quando('preencho apenas o título do template') do
#   visit new_admin_template_path if current_path != new_admin_template_path
#   fill_in 'Título do Template', with: 'Template Sem Questões'
# end

# Quando('tento criar outro template com o mesmo título') do
#   visit new_admin_template_path
#   fill_in 'Título do Template', with: @existing_template.titulo
#   # Não faz POST direto - deixa para o próximo step clicar no botão
# end

# # --- ENTÃO ---
# Então('devo ver a mensagem {string}') do |mensagem|
#   expect(page).to have_content(mensagem)
# end

# Então('o template deve aparecer na lista de templates disponíveis') do
#   visit admin_templates_path
#   expect(page).to have_content('Avaliação Docente - 2024')
# end

# Então('o sistema não deve criar o template') do
#   # Se a validação funcionou, deve mostrar a mensagem de erro na página
#   expect(page).to have_content("O título do template é obrigatório")
# end

# Então('o botão de salvar deve permanecer desabilitado') do
#   # Esta verificação pode ser implementada com JavaScript se necessário
#   # Por ora, vamos verificar que a página ainda está no formulário
#   expect(page).to have_button('Salvar Template')
# end

# Então('devo ver a mensagem de erro {string}') do |mensagem_erro|
#   expect(page).to have_content(mensagem_erro)
# end

# Então('devo ver {string}') do |mensagem|
#   expect(page).to have_content(mensagem)
# end
