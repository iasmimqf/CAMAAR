# spec/requests/admin/templates_request_spec.rb
require 'rails_helper'

RSpec.describe "Admin::Templates", type: :request do
  let(:admin_user) { create(:usuario, admin: true) }
  let(:regular_user) { create(:usuario, admin: false) }
  
  describe "autenticação e autorização" do
    context "usuário não autenticado" do
      it "redireciona para login ao acessar GET /admin/templates" do
        get admin_templates_path
        expect(response).to redirect_to(new_usuario_session_path)
      end
      
      it "redireciona para login ao tentar POST /admin/templates" do
        post admin_templates_path, params: { template: { titulo: "Teste" } }
        expect(response).to redirect_to(new_usuario_session_path)
      end
    end
    
    context "usuário regular (não admin)" do
      before { sign_in regular_user }
      
      it "redireciona para root ao acessar templates" do
        get admin_templates_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end
    end
  end
  
  describe "GET /admin/templates" do
    before { sign_in admin_user }
    
    it "retorna sucesso" do
      get admin_templates_path
      expect(response).to have_http_status(:ok)
    end
    
    it "mostra título da página" do
      get admin_templates_path
      expect(response.body).to include("Gerenciamento - Templates")
    end
    
    it "mostra link para criar novo template" do
      get admin_templates_path
      expect(response.body).to include("Novo Template")
    end
    
    context "com templates existentes" do
      let!(:template) { create(:template, titulo: "Template Teste", criador: admin_user, skip_questoes_validation: true) }
      
      it "mostra templates na lista" do
        get admin_templates_path
        expect(response.body).to include("Template Teste")
        expect(response.body).to include(admin_user.email)
      end
      
      it "mostra ações de template" do
        get admin_templates_path
        expect(response.body).to include("Visualizar")
        expect(response.body).to include("Editar")
        expect(response.body).to include("Excluir")
      end
    end
    
    context "sem templates" do
      it "mostra mensagem de nenhum template" do
        get admin_templates_path
        expect(response.body).to include("Nenhum template")
      end
    end
  end
  
  describe "GET /admin/templates/new" do
    before { sign_in admin_user }
    
    it "retorna sucesso" do
      get new_admin_template_path
      expect(response).to have_http_status(:ok)
    end
    
    it "mostra formulário de criação" do
      get new_admin_template_path
      expect(response.body).to include("Criar Novo Template")
      expect(response.body).to include("Título do Template")
      expect(response.body).to include("Salvar Template")
    end
  end
  
  describe "POST /admin/templates" do
    before { sign_in admin_user }
    
    context "com dados válidos" do
      let(:valid_params) do
        {
          template: {
            titulo: "Template Criado via Request",
            questoes_attributes: [
              { enunciado: "Pergunta teste", tipo: "Texto" }
            ]
          }
        }
      end
      
      it "cria template com sucesso" do
        expect {
          post admin_templates_path, params: valid_params
        }.to change(Template, :count).by(1)
        
        expect(response).to redirect_to(admin_templates_path)
        follow_redirect!
        expect(response.body).to include("Template &#x27;Template Criado via Request&#x27; salvo com sucesso")
      end
      
      it "atribui criador corretamente" do
        post admin_templates_path, params: valid_params
        template = Template.last
        expect(template.criador).to eq(admin_user)
      end
    end
    
    context "com dados inválidos" do
      let(:invalid_params) do
        {
          template: {
            titulo: "" # título vazio
          }
        }
      end
      
      it "não cria template" do
        expect {
          post admin_templates_path, params: invalid_params
        }.not_to change(Template, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Foram encontrados os seguintes erros")
      end
    end
  end
  
  describe "GET /admin/templates/:id" do
    let!(:template) { create(:template, titulo: "Template Detalhes", criador: admin_user, skip_questoes_validation: true) }
    let!(:questao) { create(:questao, template: template, enunciado: "Pergunta exemplo", tipo: "Texto") }
    
    before { sign_in admin_user }
    
    it "retorna sucesso" do
      get admin_template_path(template)
      expect(response).to have_http_status(:ok)
    end
    
    it "mostra detalhes do template" do
      get admin_template_path(template)
      expect(response.body).to include("Template Detalhes")
      expect(response.body).to include("Pergunta exemplo")
    end
  end
  
  describe "GET /admin/templates/:id/edit" do
    let!(:template) { create(:template, titulo: "Template Editável", criador: admin_user, skip_questoes_validation: true) }
    
    before { sign_in admin_user }
    
    it "retorna sucesso" do
      get edit_admin_template_path(template)
      expect(response).to have_http_status(:ok)
    end
    
    it "mostra formulário de edição preenchido" do
      get edit_admin_template_path(template)
      expect(response.body).to include("Template Editável")
      expect(response.body).to include("Título do Template")
    end
  end
  
  describe "PATCH/PUT /admin/templates/:id" do
    let!(:template) { create(:template, titulo: "Template Original", criador: admin_user, skip_questoes_validation: true) }
    
    before { sign_in admin_user }
    
    context "com dados válidos" do
      let(:valid_params) do
        {
          template: {
            titulo: "Template Atualizado"
          }
        }
      end
      
      it "atualiza template com sucesso" do
        patch admin_template_path(template), params: valid_params
        
        expect(response).to redirect_to(admin_templates_path)
        follow_redirect!
        expect(response.body).to include("O template foi atualizado com sucesso")
        
        template.reload
        expect(template.titulo).to eq("Template Atualizado")
      end
    end
    
    context "com dados inválidos" do
      let(:invalid_params) do
        {
          template: {
            titulo: ""
          }
        }
      end
      
      it "não atualiza template" do
        original_titulo = template.titulo
        patch admin_template_path(template), params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        template.reload
        expect(template.titulo).to eq(original_titulo)
      end
    end
  end
  
  describe "DELETE /admin/templates/:id" do
    let!(:template) { create(:template, titulo: "Template para Deletar", criador: admin_user, skip_questoes_validation: true) }
    
    before { sign_in admin_user }
    
    it "deleta template com sucesso" do
      expect {
        delete admin_template_path(template)
      }.to change(Template, :count).by(-1)
      
      expect(response).to redirect_to(admin_templates_path)
      follow_redirect!
      expect(response.body).to include("O template foi excluído com sucesso")
    end
  end
  
  describe "fluxo completo de CRUD" do
    before { sign_in admin_user }
    
    it "permite criar, ver, editar e deletar template" do
      # 1. Criar
      post admin_templates_path, params: {
        template: {
          titulo: "Template Fluxo Completo",
          questoes_attributes: [
            { enunciado: "Pergunta do fluxo", tipo: "Texto" }
          ]
        }
      }
      expect(response).to redirect_to(admin_templates_path)
      
      template = Template.last
      expect(template.titulo).to eq("Template Fluxo Completo")
      
      # 2. Visualizar
      get admin_template_path(template)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Template Fluxo Completo")
      
      # 3. Editar
      get edit_admin_template_path(template)
      expect(response).to have_http_status(:ok)
      
      patch admin_template_path(template), params: {
        template: { titulo: "Template Editado" }
      }
      expect(response).to redirect_to(admin_templates_path)
      
      template.reload
      expect(template.titulo).to eq("Template Editado")
      
      # 4. Deletar
      expect {
        delete admin_template_path(template)
      }.to change(Template, :count).by(-1)
      expect(response).to redirect_to(admin_templates_path)
    end
  end
  
  describe "validação de integridade" do
    before { sign_in admin_user }
    
    it "não permite criar template com título duplicado" do
      create(:template, titulo: "Título Único", criador: admin_user, skip_questoes_validation: true)
      
      post admin_templates_path, params: {
        template: {
          titulo: "Título Único",
          questoes_attributes: [
            { enunciado: "Pergunta", tipo: "Texto" }
          ]
        }
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Já existe um template com este nome")
    end
  end
end
