# spec/services/turma_importer_service_spec.rb
require 'rails_helper'

RSpec.describe TurmaImporterService, type: :service do
  # Cria um arquivo JSON de teste temporário
  let(:turmas_json_content) do
    [
      {
        "code" => "CIC0097",
        "name" => "BANCOS DE DADOS",
        "class" => { "classCode" => "TA", "semester" => "2021.2", "time" => "35T45" }
      }
    ].to_json
  end
  let(:file) { Tempfile.new([ 'turmas', '.json' ]).tap { |f| f.write(turmas_json_content); f.rewind; } }

  subject(:service) { described_class.new(file) }

  context "com um arquivo válido" do
    it "cria uma nova Disciplina se ela não existir" do
      expect { service.call }.to change(Disciplina, :count).by(1)
    end

    it "cria uma nova Turma se ela não existir" do
      expect { service.call }.to change(Turma, :count).by(1)
    end

    it "retorna um resultado de sucesso" do
      resultado = service.call
      expect(resultado[:success]).to be true
      expect(resultado[:turmas_criadas]).to eq(1)
    end

    it "não cria duplicatas se a turma já existir" do
      # Cria os dados antes de rodar o serviço
      disciplina = FactoryBot.create(:disciplina, codigo: "CIC0097", nome: "BANCOS DE DADOS")
      FactoryBot.create(:turma, disciplina: disciplina, codigo_turma: "TA", semestre: "2021.2")

      # Espera que nenhuma nova turma ou disciplina seja criada
      expect { service.call }.not_to change(Disciplina, :count)
      expect { service.call }.not_to change(Turma, :count)
    end
  end

  context "com um arquivo inválido" do
    let(:file) { nil } # Simula nenhum arquivo enviado

    it "retorna um resultado de falha" do
      resultado = service.call
      expect(resultado[:success]).to be false
      expect(resultado[:errors]).to include("Nenhum arquivo foi enviado.")
    end
  end
end
