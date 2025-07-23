# spec/features/templates_complete_spec.rb
require 'rails_helper'

RSpec.feature "Sistema Completo de Templates", type: :feature do
  let!(:admin_user) { create(:usuario, admin: true) }
  let!(:regular_user) { create(:usuario, admin: false) }

  before do
    sign_in admin_user
  end

  describe "Criação de Templates" do
    scenario "Admin pode acessar página de criação de template" do
      visit admin_templates_path
      expect(page).to have_content("Gerenciamento - Templates")
      
      first(:link, "Novo Template").click
      expect(page).to have_content("Criar Novo Template")
      expect(page).to have_field("Título do Template")
    end

    scenario "Criação falha sem título" do
      visit new_admin_template_path
      
      click_button "Salvar Template"
      expect(page).to have_content("Foram encontrados os seguintes erros")
      expect(page).to have_content("O título do template é obrigatório")
    end

    scenario "Criação falha por exigir questões" do
      visit new_admin_template_path
      
      fill_in "Título do Template", with: "Template Sem Questões"
      click_button "Salvar Template"
      
      expect(page).to have_content("Foram encontrados os seguintes erros")
      expect(page).to have_content("Adicione pelo menos uma questão ao template")
    end
  end

  describe "Visualização de Templates" do
    let!(:template) { create(:template, titulo: "Template Exemplo", criador: admin_user, skip_questoes_validation: true) }
    let!(:questao) { create(:questao, template: template, enunciado: "Questão de teste", tipo: "Texto") }

    scenario "Admin pode ver lista de templates" do
      visit admin_templates_path
      expect(page).to have_content("Template Exemplo")
      expect(page).to have_content("Criado por #{admin_user.email}")
    end

    scenario "Admin pode visualizar detalhes de um template" do
      visit admin_template_path(template)
      expect(page).to have_content("Template Exemplo")
    end

    scenario "Templates são listados em ordem alfabética" do
      template_z = create(:template, titulo: "Zebra Template", criador: admin_user, skip_questoes_validation: true)
      template_a = create(:template, titulo: "Alpha Template", criador: admin_user, skip_questoes_validation: true)
      
      visit admin_templates_path
      
      templates_text = page.body
      alpha_position = templates_text.index("Alpha Template")
      zebra_position = templates_text.index("Zebra Template")
      
      expect(alpha_position).to be < zebra_position
    end

    scenario "Página mostra quando não há templates" do
      Template.destroy_all
      visit admin_templates_path
      expect(page).to have_content("Nenhum template")
    end
  end

  describe "Edição de Templates" do
    let!(:template) { create(:template, titulo: "Template para Editar", criador: admin_user, skip_questoes_validation: true) }
    let!(:questao) { create(:questao, template: template, enunciado: "Questão original", tipo: "Texto") }

    scenario "Admin pode editar template existente" do
      visit admin_templates_path
      
      click_link "Editar"
      
      expect(current_path).to eq(edit_admin_template_path(template))
      
      fill_in "Título do Template", with: "Template Editado"
      click_button "Salvar"
      
      expect(page).to have_content("O template foi atualizado com sucesso")
      expect(page).to have_content("Template Editado")
      expect(page).not_to have_content("Template para Editar")
    end

    scenario "Falha ao editar template sem título" do
      visit edit_admin_template_path(template)
      
      fill_in "Título do Template", with: ""
      click_button "Salvar"
      
      expect(page).to have_content("Foram encontrados os seguintes erros")
    end
  end

  describe "Exclusão de Templates" do
    let!(:template) { create(:template, titulo: "Template para Excluir", criador: admin_user, skip_questoes_validation: true) }

    scenario "Admin pode excluir template", js: true do
      visit admin_templates_path
      
      click_link "Excluir"
      
      expect(page).not_to have_content("Template para Excluir")
      expect(Template.exists?(template.id)).to be false
    end

    scenario "Exclusão sem JavaScript ainda funciona" do
      visit admin_templates_path
      
      # Para teste sem JS, simula diretamente a requisição DELETE
      page.driver.delete admin_template_path(template)
      
      visit admin_templates_path
      expect(page).not_to have_content("Template para Excluir")
      expect(Template.exists?(template.id)).to be false
    end
  end

  describe "Autorização" do
    scenario "Usuário regular não pode acessar templates admin" do
      sign_out admin_user
      sign_in regular_user
      
      visit admin_templates_path
      expect(current_path).to eq(root_path)
    end

    scenario "Visitante é redirecionado para login" do
      sign_out admin_user
      
      visit admin_templates_path
      expect(current_path).to eq(new_usuario_session_path)
    end
  end

  describe "Gerenciamento de Templates" do
    let!(:template1) { create(:template, titulo: "Template A", criador: admin_user, skip_questoes_validation: true) }
    let!(:template2) { create(:template, titulo: "Template B", criador: admin_user, skip_questoes_validation: true) }

    scenario "Admin pode navegar entre diferentes templates" do
      visit admin_templates_path
      
      expect(page).to have_content("Template A")
      expect(page).to have_content("Template B")
      
      # Visualizar template A
      first(:link, "Visualizar").click
      expect(page).to have_content("Template A")
      
      # Voltar para lista
      visit admin_templates_path
      expect(page).to have_content("Gerenciamento - Templates")
    end

    scenario "Admin pode acessar edição de templates específicos" do
      visit admin_templates_path
      
      # Editar primeiro template da lista
      first(:link, "Editar").click
      expect(page).to have_content("Título do Template")
      
      # Cancelar e voltar
      click_link "Cancelar"
      expect(current_path).to eq(admin_templates_path)
    end
  end

  describe "Integração com Sistema" do
    scenario "Templates criados via Factory funcionam corretamente" do
      template = create(:template, titulo: "Template Factory", criador: admin_user, skip_questoes_validation: true)
      questao = create(:questao, template: template, enunciado: "Pergunta teste", tipo: "Texto")
      
      visit admin_template_path(template)
      expect(page).to have_content("Template Factory")
      
      visit admin_templates_path
      expect(page).to have_content("Template Factory")
      expect(page).to have_content("1 questão")
    end

    scenario "Sistema valida corretamente títulos únicos" do
      create(:template, titulo: "Título Único", criador: admin_user, skip_questoes_validation: true)
      
      visit new_admin_template_path
      fill_in "Título do Template", with: "Título Único"
      click_button "Salvar Template"
      
      expect(page).to have_content("Foram encontrados os seguintes erros")
      expect(page).to have_content("Já existe um template com este nome")
    end
  end
end
