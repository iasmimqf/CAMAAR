require 'rails_helper'

RSpec.feature "Autenticacao Completa", type: :feature do
  let!(:existing_user) { create(:usuario, email: 'test@example.com', password: 'Password123!@#') }
  let!(:admin_user) { create(:usuario, email: 'admin@example.com', admin: true, password: 'Password123!@#') }

  describe "Login" do
    scenario "Usuario pode fazer login" do
      visit new_usuario_session_path
      
      fill_in "E-mail ou Matrícula", with: existing_user.email
      fill_in "Senha", with: "Password123!@#"
      click_button "Entrar"
      
      expect(page).to have_content("Signed in").or have_current_path(root_path)
    end

    scenario "Login falha com credenciais invalidas" do
      visit new_usuario_session_path
      
      fill_in "E-mail ou Matrícula", with: "invalido@example.com"
      fill_in "Senha", with: "Password123!@#"
      click_button "Entrar"
      
      expect(page).to have_content("Invalid")
    end

    scenario "Redirecionamento apos login" do
      visit admin_templates_path
      expect(current_path).to eq(new_usuario_session_path)
      
      fill_in "E-mail ou Matrícula", with: admin_user.email
      fill_in "Senha", with: "Password123!@#"
      click_button "Entrar"
      
      expect(current_path).to eq(admin_templates_path)
    end
  end

  describe "Autorizacao" do
    scenario "Usuario regular nao acessa admin" do
      sign_in existing_user
      
      visit admin_templates_path
      expect(current_path).to eq(root_path)
    end

    scenario "Admin acessa area administrativa" do
      sign_in admin_user
      
      visit admin_templates_path
      expect(page).to have_content("Templates")
    end

    scenario "Visitante redirecionado para login" do
      visit admin_templates_path
      expect(current_path).to eq(new_usuario_session_path)
    end
  end

  describe "Fluxo completo" do
    scenario "Login e navegacao funcionam" do
      visit admin_templates_path
      expect(current_path).to eq(new_usuario_session_path)
      
      fill_in "E-mail ou Matrícula", with: admin_user.email
      fill_in "Senha", with: "Password123!@#"
      click_button "Entrar"
      
      expect(current_path).to eq(admin_templates_path)
      
      visit root_path
      expect(response.status).to eq(200)
    end
  end
end
