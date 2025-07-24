# spec/requests/api/v1/templates_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::Templates", type: :request do
  # Cria os utilizadores de teste
  let!(:admin) { FactoryBot.create(:usuario, :admin) }
  let!(:usuario_comum) { FactoryBot.create(:usuario) }

  # Gera um token de autenticação válido para o admin
  let(:auth_headers) do
    # Simula um login para obter um token JWT real
    post '/usuarios/sign_in', params: { usuario: { login: admin.email, password: admin.password } }, as: :json
    { 'Authorization' => response.headers['Authorization'] }
  end

  # Parâmetros válidos para criar um novo template
  let(:params_validos) do
    {
      template: {
        titulo: 'Avaliação Docente - 2024',
        questoes_attributes: [
          { enunciado: 'Satisfação com a disciplina', tipo: 'Escala', obrigatoria: true, opcoes: '5,4,3,2,1' },
          { enunciado: 'Comentários', tipo: 'Texto', obrigatoria: false }
        ]
      }
    }
  end

  describe 'GET /api/v1/templates' do
    it 'retorna todos os templates do admin autenticado' do
      FactoryBot.create(:template, criador: admin, titulo: 'Template 1')
      FactoryBot.create(:template, criador: admin, titulo: 'Template 2')
      FactoryBot.create(:template, criador: FactoryBot.create(:usuario, :admin), titulo: 'Template 3') # Template de outro admin

      get '/api/v1/templates', headers: auth_headers
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(3)
      expect(json_response.first['titulo']).to eq('Template 3')
    end

    it 'retorna erro 401 se o utilizador não estiver autenticado' do
      get '/api/v1/templates' # Sem cabeçalho de autenticação
      expect(response).to have_http_status(:found) # 302
      expect(response).to redirect_to('/usuarios/sign_in')
    end
  end

  describe 'GET /api/v1/templates/:id' do
    let(:template) { FactoryBot.create(:template, criador: admin) }

    it 'retorna os detalhes de um template específico' do
      get "/api/v1/templates/#{template.id}", headers: auth_headers
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(template.id)
    end
  end

  describe 'POST /api/v1/templates' do
    context 'com parâmetros válidos' do
      it 'cria um novo template com as suas questões' do
        
        expect {
          post '/api/v1/templates', params: params_validos, headers: auth_headers
        }.to change(Template, :count).by(1).and change(Questao, :count).by(2)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['mensagem']).to include('Avaliação Docente - 2024')
      end
    end

    context 'com parâmetros inválidos' do
      it 'não cria um template sem título e retorna um erro' do
        params_invalidos = params_validos.deep_dup
        params_invalidos[:template][:titulo] = ''
        
        post '/api/v1/templates', params: params_invalidos, headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['erro']).to include("O título do template é obrigatório")
      end

      it 'não cria um template sem questões e retorna um erro' do
        params_invalidos = params_validos.deep_dup
        params_invalidos[:template][:questoes_attributes] = []
        
        post '/api/v1/templates', params: params_invalidos, headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['erro']).to include("Adicione pelo menos uma questão ao template")
      end
    end
  end

  describe 'PATCH /api/v1/templates/:id' do
    let(:template) { FactoryBot.create(:template, criador: admin) }

    it 'atualiza o título do template' do
      patch "/api/v1/templates/#{template.id}", params: { template: { titulo: 'Título Atualizado' } }, headers: auth_headers
      
      expect(response).to have_http_status(:ok)
      expect(template.reload.titulo).to eq('Título Atualizado')
    end

    it 'não atualiza o título do template para uma string vazia' do
      patch "/api/v1/templates/#{template.id}", params: { template: { titulo: '' } }, headers: auth_headers
      
      expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['erro']).to include("O título do template é obrigatório")
    end
  end

  describe 'DELETE /api/v1/templates/:id' do
    let!(:template) { FactoryBot.create(:template, criador: admin) }

    it 'remove o template' do
      expect {
        delete "/api/v1/templates/#{template.id}", headers: auth_headers
      }.to change(Template, :count).by(-1)
      
      expect(response).to have_http_status(:ok)
    end

    it 'retorna erro ao tentar remover um template que não existe' do
      # Primeiro deleta o template existente
      delete "/api/v1/templates/#{template.id}", headers: auth_headers
      
      # Tenta deletar novamente o mesmo ID
      delete "/api/v1/templates/#{template.id}", headers: auth_headers
      
      expect(response).to have_http_status(:not_found) # 404
    end
  end
end
