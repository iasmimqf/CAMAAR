# spec/controllers/admin/templates_controller_spec.rb
require 'rails_helper'

RSpec.describe Admin::TemplatesController, type: :controller do
  let(:admin_user) { create(:usuario, admin: true) }
  let(:regular_user) { create(:usuario, admin: false) }

  describe "authorization" do
    context "when user is not authenticated" do
      it "redirects to sign in for index" do
        get :index
        expect(response).to redirect_to(new_usuario_session_path)
      end

      it "redirects to sign in for new" do
        get :new
        expect(response).to redirect_to(new_usuario_session_path)
      end
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path for index" do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root path for new" do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is admin" do
      before { sign_in admin_user }

      describe "GET #index" do
        it "responds successfully" do
          get :index
          expect(response).to have_http_status(:ok)
        end
      end

      describe "GET #new" do
        it "responds successfully" do
          get :new
          expect(response).to have_http_status(:ok)
        end
      end

      describe "POST #create" do
        context "with valid parameters" do
          let(:valid_attributes) {
            {
              titulo: "Template Válido",
              questoes_attributes: {
                "0" => { enunciado: "Questão 1", tipo: "Texto" }
              }
            }
          }

          it "creates a new template" do
            expect {
              post :create, params: { template: valid_attributes }
            }.to change(Template, :count).by(1)
          end

          it "redirects to templates list" do
            post :create, params: { template: valid_attributes }
            expect(response).to redirect_to(admin_templates_path)
          end
        end

        context "with invalid parameters" do
          let(:invalid_attributes) { { titulo: "" } }

          it "does not create a template" do
            expect {
              post :create, params: { template: invalid_attributes }
            }.not_to change(Template, :count)
          end

          it "responds with unprocessable entity" do
            post :create, params: { template: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe "PATCH #update" do
        let!(:template) { create(:template, titulo: "Título Original", criador: admin_user) }

        context "with valid parameters" do
          let(:valid_attributes) { { titulo: "Título Atualizado" } }

          it "updates the template" do
            patch :update, params: { id: template.id, template: valid_attributes }
            template.reload
            expect(template.titulo).to eq("Título Atualizado")
          end

          it "redirects to templates list" do
            patch :update, params: { id: template.id, template: valid_attributes }
            expect(response).to redirect_to(admin_templates_path)
          end
        end
      end

      describe "DELETE #destroy" do
        let!(:template) { create(:template, criador: admin_user) }

        it "deletes the template" do
          expect {
            delete :destroy, params: { id: template.id }
          }.to change(Template, :count).by(-1)
        end

        it "redirects to templates list" do
          delete :destroy, params: { id: template.id }
          expect(response).to redirect_to(admin_templates_path)
        end
      end
    end
  end
end
