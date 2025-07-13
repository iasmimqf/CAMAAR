# features/step_definitions/template_steps.rb

# --- DADO ---
Dado('que estou autenticado como administrador') do
  @admin = create(:usuario, :admin)
  visit new_usuario_session_path
  fill_in 'Email', with: @admin.email
  fill_in 'Senha', with: 'password' # assumindo senha padrão do factory
  click_button 'Entrar'
end

Dado('que acesso a página de criação de templates') do
  visit new_template_path
end

Dado('que existe um template chamado {string}') do |titulo|
  create(:template, title: titulo)
end

# --- QUANDO ---
Quando('preencho o título com {string}') do |titulo|
  fill_in 'Título do Template', with: titulo
end

Quando('adiciono as seguintes questões:') do |table|
  table.hashes.each_with_index do |questao, index|
    click_link 'Adicionar Questão' unless index == 0
    
    within all('.nested-fields').last do
      select questao['Tipo'], from: 'Tipo de Questão'
      fill_in 'Enunciado', with: questao['Enunciado']
      
      if questao['Obrigatória'] == 'Sim'
        check 'Obrigatória?'
      else
        uncheck 'Obrigatória?'
      end
      
      if questao['Opções (se aplicável)'].present?
        fill_in 'Opções (separadas por vírgula)', with: questao['Opções (se aplicável)']
      end
    end
  end
end

Quando('clico em {string}') do |botao|
  click_button botao
end

Quando('deixo o campo {string} em branco') do |campo|
  fill_in campo, with: ''
end

Quando('adiciono uma questão do tipo {string} sem enunciado') do |tipo|
  click_link 'Adicionar Questão'
  within all('.nested-fields').last do
    select tipo, from: 'Tipo de Questão'
    fill_in 'Enunciado', with: ''
  end
end

Quando('não adiciono nenhuma questão') do
  # Não faz nada, propositalmente sem questões
end

# --- ENTÃO ---
Então('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o template deve aparecer na lista de templates disponíveis') do
  visit templates_path
  expect(page).to have_content('Avaliação Docente - 2024')
end

Então('o sistema não deve criar o template') do
  expect(Template.count).to eq(0)
end

Então('o botão de salvar deve permanecer desabilitado') do
  expect(page).to have_button('Salvar Template', disabled: true)
end