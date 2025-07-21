# spec/features/gerenciamento_template_spec.rb
require 'rails_helper'

RSpec.feature "Edição e Exclusão de Templates", type: :feature do
  let!(:admin_user) { create(:usuario, :admin) }

  before do
    login_as(admin_user, scope: :usuario)
  end

  scenario "Edição bem-sucedida de template" do
    template = create(:template, titulo: "Avaliação exemplo", criador: admin_user)
    
    visit admin_templates_path
    
    within("#template_#{template.id}") do
      click_link "Editar"
    end

    fill_in "Título", with: "Avaliação Atualizada"
    click_button "Salvar"

    expect(page).to have_content("O template foi atualizado com sucesso")
    expect(page).to have_current_path(admin_templates_path)
    expect(page).to have_content("Avaliação Atualizada")
    expect(page).not_to have_content("Avaliação exemplo")

    template.reload
    expect(template.titulo).to eq("Avaliação Atualizada")
  end

  scenario "Tentativa de exclusão de template com formulários existentes" do
    template = create(:template, titulo: "Template exemplo", criador: admin_user)
    formulario = create(:formulario, template: template, criador: admin_user)

    visit admin_templates_path

    within("#template_#{template.id}") do
      accept_confirm do
        click_link "Excluir"
      end
    end

    expect(page).to have_content("Não é possível excluir o template pois existem formulários associados")
    expect(page).to have_content("Template exemplo")
    
    # Verificar que o template ainda existe
    expect(Template.exists?(template.id)).to be true
    # Verificar que o formulário ainda existe
    expect(Formulario.exists?(formulario.id)).to be true
  end

  scenario "Exclusão bem-sucedida de template sem formulários" do
    template = create(:template, titulo: "Template para excluir", criador: admin_user)

    visit admin_templates_path

    within("#template_#{template.id}") do
      accept_confirm do
        click_link "Excluir"
      end
    end

    expect(page).to have_content("O template foi excluído com sucesso")
    expect(page).not_to have_content("Template para excluir")
    
    # Verificar que o template foi excluído
    expect(Template.exists?(template.id)).to be false
  end

  scenario "Falha ao editar template por erro de título" do
    template = create(:template, titulo: "Avaliação exemplo", criador: admin_user)
    original_titulo = template.titulo

    visit admin_templates_path

    within("#template_#{template.id}") do
      click_link "Editar"
    end

    fill_in "Título", with: ""
    click_button "Salvar"

    expect(page).to have_content("O título do template é obrigatório")
    expect(page).to have_current_path(edit_admin_template_path(template))

    template.reload
    expect(template.titulo).to eq(original_titulo)
  end

  scenario "Falha ao editar template com título duplicado" do
    template1 = create(:template, titulo: "Template Original", criador: admin_user)
    template2 = create(:template, titulo: "Template Duplicado", criador: admin_user)

    visit admin_templates_path

    within("#template_#{template2.id}") do
      click_link "Editar"
    end

    fill_in "Título", with: "Template Original"
    click_button "Salvar"

    expect(page).to have_content("já existe um template com este nome")
    expect(page).to have_current_path(edit_admin_template_path(template2))

    template2.reload
    expect(template2.titulo).to eq("Template Duplicado")
  end

  scenario "Editar questões de template existente" do
    template = create(:template, titulo: "Template para editar", criador: admin_user)
    questao = create(:questao, 
      template: template,
      enunciado: "Questão original",
      tipo: "Escala",
      obrigatoria: true,
      opcoes: "5,4,3,2,1"
    )

    visit edit_admin_template_path(template)

    # Editar questão existente
    within("#questao_#{questao.id}") do
      fill_in "Enunciado", with: "Questão modificada"
      select "Texto", from: "Tipo"
      uncheck "Obrigatória"
    end

    # Adicionar nova questão
    click_button "Adicionar Questão"
    within all(".questao-form").last do
      select "Escala", from: "Tipo"
      fill_in "Enunciado", with: "Nova questão"
      check "Obrigatória"
      fill_in "Opções", with: "5,4,3,2,1"
    end

    click_button "Salvar"

    expect(page).to have_content("O template foi atualizado com sucesso")
    
    template.reload
    expect(template.questoes.count).to eq(2)
    
    questao_modificada = template.questoes.find(questao.id)
    expect(questao_modificada.enunciado).to eq("Questão modificada")
    expect(questao_modificada.tipo).to eq("Texto")
    expect(questao_modificada.obrigatoria).to be false

    nova_questao = template.questoes.where.not(id: questao.id).first
    expect(nova_questao.enunciado).to eq("Nova questão")
    expect(nova_questao.tipo).to eq("Escala")
    expect(nova_questao.obrigatoria).to be true
  end

  scenario "Remover questão de template existente" do
    template = create(:template, titulo: "Template para remover questão", criador: admin_user)
    questao1 = create(:questao, template: template, enunciado: "Questão 1")
    questao2 = create(:questao, template: template, enunciado: "Questão 2")

    visit edit_admin_template_path(template)

    # Remover primeira questão
    within("#questao_#{questao1.id}") do
      click_button "Remover"
    end

    click_button "Salvar"

    expect(page).to have_content("O template foi atualizado com sucesso")
    
    template.reload
    expect(template.questoes.count).to eq(1)
    expect(template.questoes.first.enunciado).to eq("Questão 2")
    
    # Verificar que a questão foi excluída do banco
    expect(Questao.exists?(questao1.id)).to be false
    expect(Questao.exists?(questao2.id)).to be true
  end

  scenario "Template com formulários existentes não pode ter questões obrigatórias removidas" do
    template = create(:template, titulo: "Template com formulários", criador: admin_user)
    questao = create(:questao, 
      template: template, 
      enunciado: "Questão obrigatória", 
      obrigatoria: true
    )
    formulario = create(:formulario, template: template, criador: admin_user)

    visit edit_admin_template_path(template)

    # Tentar tornar questão não obrigatória
    within("#questao_#{questao.id}") do
      uncheck "Obrigatória"
    end

    click_button "Salvar"

    expect(page).to have_content("Não é possível alterar questões obrigatórias de templates com formulários existentes")
    
    questao.reload
    expect(questao.obrigatoria).to be true
  end
end
