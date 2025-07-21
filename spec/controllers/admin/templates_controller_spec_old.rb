# spec/controllers/admin/templates_controller_spec.rb
require 'rails_helper'

RSpec.describe Admin::TemplatesController, type: :controller do
  let(:admin_user) { create(:usuario, :admin) }
  let(:regular_user) { create(:usuario) }

  describe "authorization" do
    context "when user is not authenticated" do
      it "redirects to sign in" do
        get :index
        expect(response).to redirect_to(new_usuario_session_path)
      end
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path" do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is admin" do
      before { sign_in admin_user }

      describe "GET #index" do
        it "returns a successful response" do
          get :index
          expect(response).to be_successful
        end

        it "assigns @templates" do
          template = create(:template, criador: admin_user)
          get :index
          expect(assigns(:templates)).to include(template)
        end
      end

      describe "GET #show" do
        it "returns a successful response" do
          template = create(:template, criador: admin_user)
          get :show, params: { id: template.id }
          expect(response).to be_successful
        end
      end

      describe "GET #new" do
        it "returns a successful response" do
          get :new
          expect(response).to be_successful
        end

        it "assigns a new template" do
          get :new
          expect(assigns(:template)).to be_a_new(Template)
        end
      end

      describe "POST #create" do
        context "com parâmetros válidos" do
          let(:valid_attributes) do
            {
              titulo: "Avaliação Docente - 2024",
              questoes_attributes: [
                {
                  enunciado: "Satisfação com a disciplina",
                  tipo: "Escala",
                  obrigatoria: "1",
                  opcoes: "5,4,3,2,1"
                }
              ]
            }
          end

          it "creates a new Template" do
            expect {
              post :create, params: { template: valid_attributes }
            }.to change(Template, :count).by(1)
          end

          it "redirects to the templates list" do
            post :create, params: { template: valid_attributes }
            expect(response).to redirect_to(admin_templates_path)
          end
        end

        context "com título em branco" do
          let(:invalid_attributes) do
            {
              titulo: "",
              questoes_attributes: [
                {
                  enunciado: "Questão teste",
                  tipo: "Escala",
                  obrigatoria: "1",
                  opcoes: "5,4,3,2,1"
                }
              ]
            }
          end

          it "does not create a new Template" do
            expect {
              post :create, params: { template: invalid_attributes }
            }.not_to change(Template, :count)
          end

          it "renders the new template with unprocessable entity status" do
            post :create, params: { template: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response).to render_template(:new)
          end
        end
      end

      describe "PATCH #update" do
        let(:template) { create(:template, titulo: "Título Original", criador: admin_user) }

        context "com parâmetros válidos" do
          let(:new_attributes) { { titulo: "Título Atualizado" } }

          it "updates the requested template" do
            patch :update, params: { id: template.id, template: new_attributes }
            template.reload
            expect(template.titulo).to eq("Título Atualizado")
          end

          it "redirects to the templates list" do
            patch :update, params: { id: template.id, template: new_attributes }
            expect(response).to redirect_to(admin_templates_path)
          end
        end
      end

      describe "DELETE #destroy" do
        let!(:template) { create(:template, criador: admin_user) }

        context "template sem formulários associados" do
          it "destroys the requested template" do
            expect {
              delete :destroy, params: { id: template.id }
            }.to change(Template, :count).by(-1)
          end

          it "redirects to the templates list" do
            delete :destroy, params: { id: template.id }
            expect(response).to redirect_to(admin_templates_path)
          end
        end
      end
    end
  end
end
