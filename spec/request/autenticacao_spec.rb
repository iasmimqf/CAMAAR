# spec/requests/authentication_spec.rb
require 'rails_helper'

RSpec.describe "API de Autenticação", type: :request do

  # Define os cabeçalhos que vamos usar para todas as requisições JSON
  let(:headers) do
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  # Cria os usuários de teste. Usar `let!` garante que eles sejam criados
  # antes de cada teste 'it'.
  let!(:admin) { FactoryBot.create(:usuario, :admin, email: 'admin@email.com', password: 'Password@123') }
  let!(:aluno) { FactoryBot.create(:usuario, email: 'aluno@email.com', password: 'Password@123') }

  describe "POST /login" do
    context "com credenciais válidas de admin" do
      it "autentica com sucesso e retorna um token JWT" do
        # Monta os parâmetros que serão enviados como JSON
        login_params = {
          usuario: {
            login: 'admin@email.com',
            password: 'Password@123'
          }
        }.to_json

        # Faz a requisição, incluindo os cabeçalhos e os parâmetros em JSON
        post '/usuarios/sign_in', params: login_params, headers: headers

        # --- Verificações ---
        expect(response).to have_http_status(:ok) # Status 200
        expect(response.headers['Authorization']).to include('Bearer') # O token foi retornado

        json_response = JSON.parse(response.body)
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
      # Primeiro, fazemos o login para obter um token
      login_params = { usuario: { login: aluno.email, password: aluno.password } }.to_json
      post '/usuarios/sign_in', params: login_params, headers: headers
      token = response.headers['Authorization']

      # Agora, fazemos a requisição de logout com o token
      logout_headers = headers.merge('Authorization': token)
      delete '/logout', headers: logout_headers

      expect(response).to have_http_status(:ok)
    end
  end
end