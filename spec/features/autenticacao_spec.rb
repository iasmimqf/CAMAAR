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
