# --- DADO (Setup do Cenário) ---

Dado('que o usuário {string} solicitou uma redefinição de senha') do |email|
  # Cria o usuário e gera o token de redefinição
  @user = create(:usuario, email: email, password: "SenhaEsquecida!123")
  @reset_token = @user.send_reset_password_instructions
end

# --- QUANDO (Ação do Usuário) ---

Quando('eu visito a página de redefinição de senha com o token do usuário {string}') do |email|
  # Visita a página de redefinição com o token válido
  visit edit_usuario_password_path(reset_password_token: @reset_token)
end

Quando('eu preencho o campo {string} com {string}') do |campo, valor|
  # Preenche os campos do formulário web
  case campo
  when "Nova Senha"
    fill_in 'usuario_password', with: valor
  when "Confirmação de Senha"
    fill_in 'usuario_password_confirmation', with: valor
  end
end

Quando('clico no botão Alterar minha senha') do
  # Tenta diferentes variações de botão que o Devise pode usar
  begin
    click_button 'Alterar minha senha'
  rescue Capybara::ElementNotFound
    begin
      click_button 'Change my password'
    rescue Capybara::ElementNotFound
      begin
        click_button 'Update password'
      rescue Capybara::ElementNotFound
        click_button 'commit'
      end
    end
  end
end

Quando('eu tento submeter a redefinição com o token inválido {string}') do |invalid_token|
  # Visita a página com token inválido
  visit edit_usuario_password_path(reset_password_token: invalid_token)
  fill_in 'usuario_password', with: 'any_password'
  fill_in 'usuario_password_confirmation', with: 'any_password'
  
  # Tenta diferentes variações de botão
  begin
    click_button 'Alterar minha senha'
  rescue Capybara::ElementNotFound
    begin
      click_button 'Change my password'
    rescue Capybara::ElementNotFound
      begin
        click_button 'Update password'
      rescue Capybara::ElementNotFound
        click_button 'commit'
      end
    end
  end
end

Então('eu devo ser redirecionado para a página de {string}') do |path|
  # Verifica se foi redirecionado para a página correta
  expect(current_path).to eq(path)
end

# Step definitions específicos para evitar ambiguidade
Então('eu devo ver a mensagem de redefinição {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('eu devo ver a mensagem de erro de redefinição {string}') do |mensagem_de_erro|
  expect(page).to have_content(mensagem_de_erro)
end
