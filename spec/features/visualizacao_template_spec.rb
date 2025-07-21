# spec/features/visualizacao_template_spec.rb
require 'rails_helper'

RSpec.feature "Visualização de Templates Criados", type: :feature do
  let!(:admin_user) { create(:usuario, :admin) }

  before do
    login_as(admin_user, scope: :usuario)
  end

  scenario "Listagem de templates" do
    template1 = create(:template, titulo: "Avaliação exemplo", criador: admin_user)
    template2 = create(:template, titulo: "Avaliação exemplo2", criador: admin_user)
    template3 = create(:template, titulo: "Avaliação exemplo3", criador: admin_user)

    visit admin_templates_path

    expect(page).to have_content("Avaliação exemplo")
    expect(page).to have_content("Avaliação exemplo2")
    expect(page).to have_content("Avaliação exemplo3")

    # Verificar botões Editar e Excluir para cada template
    within("#template_#{template1.id}") do
      expect(page).to have_link("Editar")
      expect(page).to have_link("Excluir")
    end

    within("#template_#{template2.id}") do
      expect(page).to have_link("Editar")
      expect(page).to have_link("Excluir")
    end

    within("#template_#{template3.id}") do
      expect(page).to have_link("Editar")
      expect(page).to have_link("Excluir")
    end
  end

  scenario "Nenhum template cadastrado no sistema" do
    visit admin_templates_path

    expect(page).to have_content("Nenhum template foi encontrado")
    expect(page).not_to have_link("Editar")
    expect(page).not_to have_link("Excluir")
  end

  scenario "Visualizar detalhes de um template específico" do
    template = create(:template, titulo: "Template Detalhado", criador: admin_user)
    questao1 = create(:questao, 
      template: template,
      enunciado: "Como você avalia o professor?",
      tipo: "Escala",
      obrigatoria: true,
      opcoes: "5,4,3,2,1"
    )
    questao2 = create(:questao,
      template: template,
      enunciado: "Comentários adicionais",
      tipo: "Texto",
      obrigatoria: false
    )

    visit admin_template_path(template)

    expect(page).to have_content("Template Detalhado")
    expect(page).to have_content("Como você avalia o professor?")
    expect(page).to have_content("Escala")
    expect(page).to have_content("Obrigatória: Sim")
    expect(page).to have_content("Opções: 5,4,3,2,1")
    
    expect(page).to have_content("Comentários adicionais")
    expect(page).to have_content("Texto")
    expect(page).to have_content("Obrigatória: Não")
  end

  scenario "Templates ordenados alfabeticamente por título" do
    create(:template, titulo: "Zebra Template", criador: admin_user)
    create(:template, titulo: "Alpha Template", criador: admin_user)
    create(:template, titulo: "Beta Template", criador: admin_user)

    visit admin_templates_path

    template_titles = page.all('.template-title').map(&:text)
    expect(template_titles).to eq(["Alpha Template", "Beta Template", "Zebra Template"])
  end

  scenario "Exibir informações do criador do template" do
    other_admin = create(:usuario, :admin, nome: "Outro Admin")
    template = create(:template, titulo: "Template Criado", criador: other_admin)

    visit admin_templates_path

    within("#template_#{template.id}") do
      expect(page).to have_content("Criado por: Outro Admin")
    end
  end

  scenario "Exibir data de criação do template" do
    template = create(:template, titulo: "Template com Data", criador: admin_user)

    visit admin_templates_path

    within("#template_#{template.id}") do
      expect(page).to have_content(template.created_at.strftime("%d/%m/%Y"))
    end
  end

  scenario "Link para criar novo template" do
    visit admin_templates_path

    expect(page).to have_link("Novo Template", href: new_admin_template_path)
  end

  scenario "Contagem de questões por template" do
    template = create(:template, titulo: "Template com Questões", criador: admin_user)
    create(:questao, template: template, enunciado: "Questão 1")
    create(:questao, template: template, enunciado: "Questão 2")
    create(:questao, template: template, enunciado: "Questão 3")

    visit admin_templates_path

    within("#template_#{template.id}") do
      expect(page).to have_content("3 questões")
    end
  end

  scenario "Template sem questões deve mostrar aviso" do
    template = create(:template, titulo: "Template Vazio", criador: admin_user)

    visit admin_templates_path

    within("#template_#{template.id}") do
      expect(page).to have_content("Nenhuma questão")
      expect(page).to have_css(".warning-icon")
    end
  end

  scenario "Filtrar templates por título" do
    create(:template, titulo: "Avaliação Docente", criador: admin_user)
    create(:template, titulo: "Avaliação Disciplina", criador: admin_user)
    create(:template, titulo: "Feedback Estudantil", criador: admin_user)

    visit admin_templates_path

    fill_in "Buscar templates", with: "Avaliação"
    click_button "Buscar"

    expect(page).to have_content("Avaliação Docente")
    expect(page).to have_content("Avaliação Disciplina")
    expect(page).not_to have_content("Feedback Estudantil")
  end
end
