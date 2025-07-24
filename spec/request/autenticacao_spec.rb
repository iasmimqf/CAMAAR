require 'rails_helper'

RSpec.describe "API de Autenticação", type: :request do
  let(:headers) do
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  let!(:admin) { FactoryBot.create(:usuario, :admin, email: 'admin@email.com', password: 'Password@123') }
  let!(:aluno) { FactoryBot.create(:usuario, email: 'aluno@email.com', password: 'Password@123') }

  describe "POST /usuarios/sign_in" do
    context "com credenciais válidas de admin" do
      it "autentica com sucesso e retorna os dados do usuário admin" do
        login_params = {
          usuario: {
            login: 'admin@email.com',
            password: 'Password@123'
          }
        }.to_json

        post '/usuarios/sign_in', params: login_params, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['email']).to eq('admin@email.com')
        expect(json_response['data']['admin']).to be true
      end
    end

    context "com senha incorreta" do
      it "retorna um erro de não autorizado (401)" do
        login_params = {
          usuario: {
            login: 'admin@email.com',
            password: 'senha-errada'
          }
        }.to_json

        post '/usuarios/sign_in', params: login_params, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /logout" do
    it "desloga o usuário com sucesso" do
      # Login para autenticar
      login_params = {
        usuario: {
          login: aluno.email,
          password: 'Password@123'
        }
      }.to_json

      post '/usuarios/sign_in', params: login_params, headers: headers

      delete '/usuarios/sign_out', headers: headers

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
