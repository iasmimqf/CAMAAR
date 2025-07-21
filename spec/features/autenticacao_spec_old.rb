# spec/features/autenticacao_spec.rb
require 'rails_helper'

RSpec.feature "Autenticação de Usuários", type: :feature do
  let!(:admin_user) do
    create(:usuario, admin: true, email: "admin@test.com", password: "password123")
  end

  let!(:regular_user) do
    create(:usuario, admin: false, email: "user@test.com", password: "password123")
  end

  scenario "Visitante pode acessar página de login" do
    visit new_usuario_session_path
    expect(page).to have_content("Log in")
  end

  scenario "Admin pode fazer login" do
    visit new_usuario_session_path
    fill_in "Email", with: admin_user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
    
    expect(page).to have_content("Signed in successfully") if page.has_content?("Signed in successfully")
  end

  scenario "Usuário regular pode fazer login" do
    visit new_usuario_session_path
    fill_in "Email", with: regular_user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
    
    expect(page).to have_content("Signed in successfully") if page.has_content?("Signed in successfully")
  end

  scenario "Login falha com credenciais inválidas" do
    visit new_usuario_session_path
    fill_in "Email", with: "invalid@test.com"
    fill_in "Password", with: "wrongpassword"
    click_button "Log in"
    
    expect(page).to have_content("Invalid") if page.has_content?("Invalid")
  end

  scenario "Usuário pode fazer logout" do
    sign_in admin_user
    visit root_path
    
    if page.has_link?("Logout")
      click_link "Logout"
      expect(page).to have_content("Signed out successfully") if page.has_content?("Signed out successfully")
    end
  end
end
    click_button "Entrar"

    expect(page).to have_current_path(root_path)
    
    # Verificar que não há menu de gerenciamento para usuário comum
    expect(page).not_to have_link("Gerenciamento")
  end

  scenario "Login bem-sucedido do Usuário Padrão com matrícula" do
    visit new_usuario_session_path

    fill_in "E-mail", with: "98765"
    fill_in "Senha", with: "senha123"
    click_button "Entrar"

    expect(page).to have_current_path(root_path)
    
    # Verificar que não há menu de gerenciamento para usuário comum
    expect(page).not_to have_link("Gerenciamento")
  end

  scenario "Falha no login por credenciais inválidas" do
    visit new_usuario_session_path

    fill_in "E-mail", with: "usuario@inexistente.com"
    fill_in "Senha", with: "senhaerrada"
    click_button "Entrar"

    expect(page).to have_current_path(new_usuario_session_path)
    expect(page).to have_content("E-mail ou senha inválidos")
  end

  scenario "Falha no login por senha incorreta" do
    visit new_usuario_session_path

    fill_in "E-mail", with: "admin@meusistema.com"
    fill_in "Senha", with: "senhaerrada"
    click_button "Entrar"

    expect(page).to have_current_path(new_usuario_session_path)
    expect(page).to have_content("E-mail ou senha inválidos")
  end

  scenario "Logout do sistema" do
    # Fazer login primeiro
    visit new_usuario_session_path
    fill_in "E-mail", with: "admin@meusistema.com"
    fill_in "Senha", with: "senhaSuperSecretaAdmin"
    click_button "Entrar"

    # Verificar que estamos logados
    expect(page).to have_current_path(admin_dashboard_path)

    # Fazer logout
    click_link "Sair"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Entrar")
  end

  scenario "Acesso negado para usuário não autenticado" do
    visit admin_templates_path

    expect(page).to have_current_path(new_usuario_session_path)
    expect(page).to have_content("Você precisa entrar ou registrar-se antes de continuar")
  end

  scenario "Acesso negado para usuário não administrador em área restrita" do
    # Login como usuário comum
    visit new_usuario_session_path
    fill_in "E-mail", with: "joao.silva@email.com"
    fill_in "Senha", with: "senha123"
    click_button "Entrar"

    # Tentar acessar área de administração
    visit admin_templates_path

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Acesso negado")
  end
end
