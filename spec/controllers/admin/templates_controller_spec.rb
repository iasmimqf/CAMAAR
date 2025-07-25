# spec/controllers/admin/templates_controller_spec.rb
require 'rails_helper'

RSpec.describe Admin::TemplatesController, type: :controller do
  let(:admin_user) { create(:usuario, admin: true) }
  let(:regular_user) { create(:usuario, admin: false) }
  let(:template) { create(:template, criador: admin_user, skip_questoes_validation: true) }
  
  describe "autenticação e autorização" do
    context "usuário não autenticado" do
      it "redireciona para login em GET #index" do
        get :index
        expect(response).to redirect_to(new_usuario_session_path)
      end
      
      it "redireciona para login em GET #new" do
        get :new
        expect(response).to redirect_to(new_usuario_session_path)
      end
    end
    
    context "usuário regular (não admin)" do
      before { sign_in regular_user }
      
      it "redireciona para root em GET #index" do
        get :index
        expect(response).to redirect_to(root_path)
      end
      
      it "redireciona para root em GET #new" do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe "GET #index" do
    before { sign_in admin_user }
    
    it "retorna sucesso" do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it "atribui @templates ordenados por título" do
      template_b = create(:template, titulo: "Template B", criador: admin_user, skip_questoes_validation: true)
      template_a = create(:template, titulo: "Template A", criador: admin_user, skip_questoes_validation: true)
      
      get :index
      expect(assigns(:templates)).to eq([template_a, template_b])
    end
  end
  
  describe "GET #show" do
    before { sign_in admin_user }
    
    it "retorna sucesso" do
      get :show, params: { id: template.id }
      expect(response).to have_http_status(:success)
    end
    
    it "atribui o template correto" do
      get :show, params: { id: template.id }
      expect(assigns(:template)).to eq(template)
    end
  end
  
  describe "GET #new" do
    before { sign_in admin_user }
    
    it "retorna sucesso" do
      get :new
      expect(response).to have_http_status(:success)
    end
    
    it "atribui um novo template" do
      get :new
      expect(assigns(:template)).to be_a_new(Template)
    end
  end
  
  describe "GET #edit" do
    before { sign_in admin_user }
    
    it "retorna sucesso" do
      get :edit, params: { id: template.id }
      expect(response).to have_http_status(:success)
    end
    
    it "atribui o template correto" do
      get :edit, params: { id: template.id }
      expect(assigns(:template)).to eq(template)
    end
  end
  
  describe "POST #create" do
    before { sign_in admin_user }
    
    context "com parâmetros válidos" do
      let(:valid_params) do
        {
          template: {
            titulo: "Novo Template",
            questoes_attributes: [
              { enunciado: "Pergunta 1", tipo: "Texto" }
            ]
          }
        }
      end
      
      it "cria um novo template" do
        expect {
          post :create, params: valid_params
        }.to change(Template, :count).by(1)
      end
      
      it "atribui o criador correto" do
        post :create, params: valid_params
        expect(assigns(:template).criador).to eq(admin_user)
      end
      
      it "redireciona para index com sucesso" do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_templates_path)
        expect(flash[:notice]).to match(/Template .* salvo com sucesso/)
      end
    end
    
    context "com parâmetros inválidos" do
      let(:invalid_params) do
        {
          template: {
            titulo: ""
          }
        }
      end
      
      it "não cria template" do
        expect {
          post :create, params: invalid_params
        }.not_to change(Template, :count)
      end
      
      it "renderiza new com erro" do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end
  end
  
  describe "PATCH #update" do
    before { sign_in admin_user }
    
    context "com parâmetros válidos" do
      let(:valid_params) do
        {
          id: template.id,
          template: {
            titulo: "Template Atualizado"
          }
        }
      end
      
      it "atualiza o template" do
        patch :update, params: valid_params
        template.reload
        expect(template.titulo).to eq("Template Atualizado")
      end
      
      it "redireciona para index com sucesso" do
        patch :update, params: valid_params
        expect(response).to redirect_to(admin_templates_path)
        expect(flash[:notice]).to eq("O template foi atualizado com sucesso.")
      end
    end
    
    context "com parâmetros inválidos" do
      let(:invalid_params) do
        {
          id: template.id,
          template: {
            titulo: ""
          }
        }
      end
      
      it "não atualiza o template" do
        original_titulo = template.titulo
        patch :update, params: invalid_params
        template.reload
        expect(template.titulo).to eq(original_titulo)
      end
      
      it "renderiza edit com erro" do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end
  end
  
  describe "DELETE #destroy" do
    before { sign_in admin_user }
    
    it "destroi o template" do
      template_to_delete = create(:template, criador: admin_user, skip_questoes_validation: true)
      
      expect {
        delete :destroy, params: { id: template_to_delete.id }
      }.to change(Template, :count).by(-1)
    end
    
    it "redireciona para index com sucesso" do
      delete :destroy, params: { id: template.id }
      expect(response).to redirect_to(admin_templates_path)
      expect(flash[:notice]).to eq("O template foi excluído com sucesso.")
    end
  end
end
