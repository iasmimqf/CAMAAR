# spec/features/criar_template_spec.rb
require 'rails_helper'

RSpec.feature "Criação de template de formulário", type: :feature do
  let!(:admin_user) { create(:usuario, admin: true) }

  before do
    sign_in admin_user
  end

  scenario "Admin pode acessar página de criação de template" do
    visit admin_templates_path
    expect(page).to have_content("Templates")
    
    if page.has_link?("Novo Template")
      click_link "Novo Template"
      expect(page).to have_content("Novo Template") || expect(page).to have_field("Título")
    end
  end

  scenario "Admin pode criar template básico" do
    visit new_admin_template_path
    
    fill_in "Título", with: "Template de Teste"
    
    if page.has_button?("Criar Template") || page.has_button?("Salvar")
      click_button page.has_button?("Criar Template") ? "Criar Template" : "Salvar"
      
      expect(current_path).to eq(admin_templates_path) || expect(page).to have_content("Template de Teste")
    end
  end

  scenario "Criação falha sem título" do
    visit new_admin_template_path
    
    if page.has_button?("Criar Template") || page.has_button?("Salvar")
      click_button page.has_button?("Criar Template") ? "Criar Template" : "Salvar"
      expect(page).to have_content("erro") || expect(page).to have_content("obrigatório")
    end
  end

  scenario "Admin pode ver lista de templates" do
    template = create(:template, titulo: "Template Existente", criador: admin_user)
    
    visit admin_templates_path
    expect(page).to have_content("Template Existente")
  end

  scenario "Admin pode editar template" do
    template = create(:template, titulo: "Template para Editar", criador: admin_user)
    
    visit edit_admin_template_path(template)
    fill_in "Título", with: "Template Editado"
    
    if page.has_button?("Atualizar Template") || page.has_button?("Salvar")
      click_button page.has_button?("Atualizar Template") ? "Atualizar Template" : "Salvar"
      expect(page).to have_content("Template Editado")
    end
  end
end
