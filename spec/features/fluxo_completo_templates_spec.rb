# spec/features/fluxo_completo_templates_spec.rb
require 'rails_helper'

RSpec.feature "Fluxo completo de Templates", type: :feature do
  let!(:admin_user) { create(:usuario, :admin, nome: "Admin Teste") }

  before do
    login_as(admin_user, scope: :usuario)
  end

  scenario "Criar, visualizar, editar e tentar excluir template" do
    # 1. Acessar página de templates
    visit admin_templates_path
    expect(page).to have_content("Nenhum template foi encontrado")

    # 2. Criar novo template
    click_link "Novo Template"
    expect(page).to have_current_path(new_admin_template_path)

    fill_in "Título", with: "Avaliação Completa"

    # Adicionar questão de escala
    click_button "Adicionar Questão"
    within first(".questao-form") do
      select "Escala", from: "Tipo"
      fill_in "Enunciado", with: "Como você avalia o professor?"
      check "Obrigatória"
      fill_in "Opções", with: "Excelente,Bom,Regular,Ruim,Péssimo"
    end

    # Adicionar questão de texto
    click_button "Adicionar Questão"
    within all(".questao-form").last do
      select "Texto", from: "Tipo"
      fill_in "Enunciado", with: "Deixe seus comentários"
      uncheck "Obrigatória"
    end

    click_button "Salvar Template"

    # 3. Verificar criação bem-sucedida
    expect(page).to have_content("Template 'Avaliação Completa' salvo com sucesso")
    expect(page).to have_current_path(admin_templates_path)
    expect(page).to have_content("Avaliação Completa")
    expect(page).to have_content("Criado por: Admin Teste")

    # 4. Visualizar detalhes do template
    template = Template.find_by(titulo: "Avaliação Completa")
    visit admin_template_path(template)

    expect(page).to have_content("Avaliação Completa")
    expect(page).to have_content("Como você avalia o professor?")
    expect(page).to have_content("Escala")
    expect(page).to have_content("Obrigatória: Sim")
    expect(page).to have_content("Excelente,Bom,Regular,Ruim,Péssimo")
    
    expect(page).to have_content("Deixe seus comentários")
    expect(page).to have_content("Texto")
    expect(page).to have_content("Obrigatória: Não")

    # 5. Editar template
    visit admin_templates_path
    within("#template_#{template.id}") do
      click_link "Editar"
    end

    fill_in "Título", with: "Avaliação Atualizada"

    # Modificar primeira questão
    within("#questao_#{template.questoes.first.id}") do
      fill_in "Enunciado", with: "Como você avalia o docente da disciplina?"
      fill_in "Opções", with: "5,4,3,2,1"
    end

    # Adicionar terceira questão
    click_button "Adicionar Questão"
    within all(".questao-form").last do
      select "Escala", from: "Tipo"
      fill_in "Enunciado", with: "Recomendaria esta disciplina?"
      check "Obrigatória"
      fill_in "Opções", with: "Sim,Não"
    end

    click_button "Salvar"

    # 6. Verificar edição bem-sucedida
    expect(page).to have_content("O template foi atualizado com sucesso")
    expect(page).to have_content("Avaliação Atualizada")
    expect(page).not_to have_content("Avaliação Completa")

    template.reload
    expect(template.titulo).to eq("Avaliação Atualizada")
    expect(template.questoes.count).to eq(3)

    # 7. Criar formulário usando o template (simular)
    formulario = create(:formulario, template: template, criador: admin_user)

    # 8. Tentar excluir template com formulários
    visit admin_templates_path
    within("#template_#{template.id}") do
      accept_confirm do
        click_link "Excluir"
      end
    end

    expect(page).to have_content("Não é possível excluir o template pois existem formulários associados")
    expect(page).to have_content("Avaliação Atualizada")

    # Verificar que template ainda existe
    expect(Template.exists?(template.id)).to be true
    expect(Formulario.exists?(formulario.id)).to be true

    # 9. Remover formulário e tentar excluir novamente
    formulario.destroy

    visit admin_templates_path
    within("#template_#{template.id}") do
      accept_confirm do
        click_link "Excluir"
      end
    end

    # 10. Verificar exclusão bem-sucedida
    expect(page).to have_content("O template foi excluído com sucesso")
    expect(page).not_to have_content("Avaliação Atualizada")
    expect(page).to have_content("Nenhum template foi encontrado")
    expect(Template.exists?(template.id)).to be false
  end

  scenario "Fluxo com validações e erros" do
    # 1. Criar template com erro
    visit new_admin_template_path
    click_button "Salvar Template"

    expect(page).to have_content("O título do template é obrigatório")
    expect(page).to have_content("Adicione pelo menos uma questão ao template")

    # 2. Preencher título mas deixar questão incompleta
    fill_in "Título", with: "Template com erro"
    click_button "Adicionar Questão"
    
    within first(".questao-form") do
      select "Escala", from: "Tipo"
      # Não preencher enunciado
      check "Obrigatória"
      fill_in "Opções", with: "5,4,3,2,1"
    end

    click_button "Salvar Template"
    expect(page).to have_content("Existem questões incompletas")

    # 3. Corrigir e salvar
    within first(".questao-form") do
      fill_in "Enunciado", with: "Questão corrigida"
    end

    click_button "Salvar Template"
    expect(page).to have_content("Template 'Template com erro' salvo com sucesso")

    # 4. Tentar criar template com mesmo título
    click_link "Novo Template"
    fill_in "Título", with: "Template com erro"
    
    click_button "Adicionar Questão"
    within first(".questao-form") do
      select "Texto", from: "Tipo"
      fill_in "Enunciado", with: "Nova questão"
    end

    click_button "Salvar Template"
    expect(page).to have_content("Já existe um template com este nome")
    expect(Template.where(titulo: "Template com erro").count).to eq(1)
  end
end
