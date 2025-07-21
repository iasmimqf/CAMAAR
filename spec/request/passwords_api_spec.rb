# spec/requests/passwords_api_spec.rb
require 'rails_helper'

RSpec.describe "API de Redefinição de Senha", type: :request do
  let!(:aluno) { FactoryBot.create(:usuario, email: 'ana@email.com', matricula: '12345', password: 'Password@123') }

  # --- Testando a SOLICITAÇÃO de redefinição  ---
  describe "POST /api/v1/password (forgot)" do
    context "quando o usuário existe" do
      it "enfileira um e-mail de redefinição de senha e retorna sucesso" do
        # O expect aninhado verifica se o código dentro do bloco {}
        # muda o tamanho da fila de e-mails em +1.
        expect {
          post '/api/v1/password', params: { login: 'ana@email.com' }
        }.to change { ActionMailer::Base.deliveries.size }.by(1)

        # Verifica se a resposta da API foi '200 OK'
        expect(response).to have_http_status(:ok)
        
        # Verifica se a mensagem de segurança foi retornada
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to include('você receberá um link')
      end
    end

    context "quando o usuário NÃO existe" do
      it "NÃO enfileira um e-mail, mas ainda retorna sucesso por segurança" do
        expect {
          post '/api/v1/password', params: { login: 'fantasma@email.com' }
        }.not_to change { ActionMailer::Base.deliveries.size }

        expect(response).to have_http_status(:ok)
      end
    end
  end


  # --- Testando a AÇÃO de redefinição ---
  describe "PUT /api/v1/password (reset)" do
    # 'let' é preguiçoso, então o token só é gerado quando 'reset_token' é chamado pela primeira vez.
    let(:reset_token) { aluno.send_reset_password_instructions }

    context "com um token válido" do
      it "redefine a senha com sucesso" do
        put '/api/v1/password', params: {
          reset_password_token: reset_token,
          password: 'NovaSenhaForte@123',
          password_confirmation: 'NovaSenhaForte@123'
        }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Sua senha foi redefinida com sucesso.')
        
        # Verifica se a nova senha realmente funciona
        expect(aluno.reload.valid_password?('NovaSenhaForte@123')).to be true
      end

      it "retorna erro se as senhas não conferem (sad path)" do
        put '/api/v1/password', params: {
          reset_password_token: reset_token,
          password: 'NovaSenhaForte@123',
          password_confirmation: 'outra-senha-diferente'
        }

        expect(response).to have_http_status(:unprocessable_entity) # Status 422
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Confirmação de Senha não corresponde à Senha")
      end

      it "retorna erro se a senha for fraca (sad path)" do
        put '/api/v1/password', params: {
          reset_password_token: reset_token,
          password: 'fraca',
          password_confirmation: 'fraca'
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        # A mensagem exata vai depender da sua validação `password_complexity`
        expect(json_response['errors'].first).to include("é muito curta")
      end
    end

    context "com um token inválido ou expirado (sad path)" do
      it "retorna um erro" do
        put '/api/v1/password', params: {
          reset_password_token: 'token-invalido',
          password: 'NovaSenhaForte@123',
          password_confirmation: 'NovaSenhaForte@123'
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors'].first).to include("Token de redefinição de senha é inválido")
      end
    end
  end
end