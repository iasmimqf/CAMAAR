# spec/requests/admin/importacoes_spec.rb
require 'rails_helper'

RSpec.describe "Admin::ImportacoesController", type: :request do
  let(:admin) { FactoryBot.create(:usuario, :admin, password: "Password@123") }

  # Autentica o admin antes de cada teste neste bloco
  before do
    sign_in admin
  end

  describe "POST /admin/importacoes/importar_alunos" do
    let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/alunos.json'), 'application/json') }

    context "quando a importação é bem-sucedida" do
      it "chama o AlunoImporterService e retorna uma resposta de sucesso" do
        # 1. Cria um "dublê" do nosso serviço
        importer_double = instance_double(AlunoImporterService)
        
        # 2. Diz ao RSpec: "Quando 'AlunoImporterService.new' for chamado,
        #    em vez de criar um serviço de verdade, retorne o nosso dublê."
        allow(AlunoImporterService).to receive(:new).and_return(importer_double)
        
        # 3. Diz ao RSpec: "Eu espero que o método 'call' seja chamado no nosso dublê,
        #    e quando for, ele deve retornar um resultado de sucesso."
        allow(importer_double).to receive(:call).and_return({ success: true, details: { alunos_criados: 5 } })

        # 4. Ação: Faz a requisição para o controller
        post admin_importar_alunos_path, params: { file: file }

        # 5. Verificação: O controller chamou o serviço como esperado?
        expect(AlunoImporterService).to have_received(:new).with(file)
        expect(importer_double).to have_received(:call)
        
        # 6. Verificação: O controller renderizou a resposta JSON correta?
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['notice']).to include("Importação concluída!")
      end
    end

    context "quando a importação falha" do
      it "chama o AlunoImporterService e retorna uma resposta de erro" do
        importer_double = instance_double(AlunoImporterService)
        allow(AlunoImporterService).to receive(:new).and_return(importer_double)
        # Simula o serviço retornando um erro
        allow(importer_double).to receive(:call).and_return({ success: false, errors: ["Turma não encontrada"] })

        post admin_importar_alunos_path, params: { file: file }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Turma não encontrada")
      end
    end
  end
end