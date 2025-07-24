# features/step_definitions/definicao_de_senha_steps.rb

# --- DADO ---

Dado('que o usuário {string} solicitou uma redefinição de senha') do |email|
  @usuario = create(:usuario, email: email, password: 'OldPassword123!')
end

# --- QUANDO ---

Quando('eu visito a página de redefinição de senha com o token do usuário {string}') do |email|
  # Busca o usuário pelo email
  usuario = Usuario.find_by(email: email)
  
  if usuario
    # Gera o token manualmente usando métodos do Devise
    raw_token, encrypted_token = Devise.token_generator.generate(Usuario, :reset_password_token)
    
    # Define o token no usuário sem enviar email
    usuario.reset_password_token = encrypted_token
    usuario.reset_password_sent_at = Time.current
    usuario.save!
    
    # Usa o token raw (não criptografado) na URL
    visit edit_usuario_password_path(reset_password_token: raw_token)
  else
    visit edit_usuario_password_path(reset_password_token: 'TOKEN_INVALIDO')
  end
end

Quando('eu visito a página de redefinição de senha com o token {string}') do |token|
  # Visita diretamente com o token fornecido
  visit edit_usuario_password_path(reset_password_token: token)
end

Quando('preencho o campo {string} com {string}') do |campo, valor|
  case campo
  when "Nova Senha", "New password"
    fill_in 'usuario[password]', with: valor
  when "Confirmação de Senha", "Confirm new password"  
    fill_in 'usuario[password_confirmation]', with: valor
  else
    # Tenta encontrar o campo pelo label
    fill_in campo, with: valor
  end
end

Quando('clico no botão de redefinir senha {string}') do |botao|
  if botao == "Alterar minha senha"
    click_button 'Change my password'
  end
end

# --- ENTÃO ---

Então('eu não devo ver o campo {string}') do |campo|
  case campo
  when "Nova Senha", "New password"
    expect(page).not_to have_field('usuario[password]')
  when "Confirmação de Senha", "Confirm new password"
    expect(page).not_to have_field('usuario[password_confirmation]')
  else
    # Tenta verificar se não existe o campo pelo nome
    expect(page).not_to have_field(campo)
  end
end

# Limpeza após os testes
After do
  # Remove tokens de reset criados durante os testes
  if @usuario
    @usuario.update(reset_password_token: nil, reset_password_sent_at: nil)
  end
end
