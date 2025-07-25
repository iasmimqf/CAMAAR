require 'rails_helper'

RSpec.describe "Admin::Formularios", type: :request do
  # Cria os utilizadores de teste com diferentes perfis
  let!(:admin) { FactoryBot.create(:usuario, :admin) }
  let!(:professor) { FactoryBot.create(:usuario) }
  let!(:usuario_comum) { FactoryBot.create(:usuario) }
  
  # Cria dados base para os testes
  let!(:template) { FactoryBot.create(:template, criador: admin) }
  let!(:turma_do_professor) { FactoryBot.create(:turma, professor: professor) }
  let!(:outra_turma) { FactoryBot.create(:turma) }

  describe 'GET /admin/formularios (index)' do
    context 'quando o utilizador é um admin' do
      # Gera um token de autenticação válido para o admin
      let(:auth_headers) do
        # Simula um login para obter um token JWT real
        post '/usuarios/sign_in', params: { usuario: { login: admin.email, password: admin.password } }, as: :json
        { 'Authorization' => response.headers['Authorization'] }
      end

      it 'mostra todos os formulários' do
        formulario1 = FactoryBot.create(:formulario, turmas: [turma_do_professor])
        formulario2 = FactoryBot.create(:formulario, turmas: [outra_turma])
        
        get admin_formularios_path, headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        # Verifica se o corpo da resposta HTML contém o título dos formulários
        expect(response.body).to include(formulario1.template.titulo)
        expect(response.body).to include(formulario2.template.titulo)
      end
    end

    context 'quando o utilizador não tem permissão' do
      let(:auth_headers) do
        # Simula um login para obter um token JWT real
        post '/usuarios/sign_in', params: { usuario: { login: usuario_comum.email, password: usuario_comum.password } }, as: :json
        { 'Authorization' => response.headers['Authorization'] }
      end

      it 'redireciona para a página inicial com um alerta' do
        get admin_formularios_path, headers: auth_headers
        
        expect(response).to redirect_to(root_path)
        follow_redirect! # Segue o redirecionamento para poder verificar o flash
        expect(response.body).to include("Acesso não autorizado. Você não tem permissão de administrador.")
      end
    end
  end

  describe 'GET /admin/formularios/new (new)' do
    let(:auth_headers) do
      # Simula um login para obter um token JWT real
      post '/usuarios/sign_in', params: { usuario: { login: admin.email, password: admin.password } }, as: :json
      { 'Authorization' => response.headers['Authorization'] }
    end

    it 'renderiza a página de criação com sucesso' do
      get new_admin_formulario_path, headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Criar Formulário")
    end
  end
end
