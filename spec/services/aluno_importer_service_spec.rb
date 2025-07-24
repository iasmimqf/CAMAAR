# spec/services/aluno_importer_service_spec.rb
require 'rails_helper'

RSpec.describe AlunoImporterService, type: :service do
  # Cria a disciplina e a turma base para a maioria dos testes
  let!(:disciplina) { FactoryBot.create(:disciplina, codigo: "CIC0097", nome: "BANCOS DE DADOS") }
  let!(:turma) { FactoryBot.create(:turma, disciplina: disciplina, codigo_turma: "TA", semestre: "2021.2", horario: "35M12") }

  # Simula os dados de um arquivo JSON válido com um novo aluno e um novo professor
  let(:dados_validos) do
    [ {
      "code" => "CIC0097",
      "classCode" => "TA",
      "semester" => "2021.2",
      "docente" => { "nome" => "Professor Novo",  "email" => "prof.novo@email.com", "usuario" => "999888" },
      "dicente" => [ { "nome" => "Aluno Novo", "matricula" => "111222", "email" => "aluno.novo@email.com" } ]
    } ]
  end

  # --- HAPPY PATH ---
  context "quando importa um arquivo com usuários novos" do
    subject(:service) { described_class.new(double(read: dados_validos.to_json, original_filename: 'alunos.json')) }

    it "cria um novo aluno e um novo professor" do
      expect { service.call }.to change(Usuario, :count).by(2) # 1 aluno + 1 professor
    end

    it "associa o professor e o aluno à turma correta" do
      service.call
      aluno = Usuario.find_by(matricula: "111222")
      professor = Usuario.find_by(matricula: "999888")

      expect(turma.reload.professor).to eq(professor)
      expect(turma.usuarios).to include(aluno)
    end

    it "envia e-mails de definição de senha para os novos usuários" do
      expect { service.call }.to change { ActionMailer::Base.deliveries.size }.by(2)
    end

    it "retorna um resultado de sucesso com os contadores corretos" do
      resultado = service.call
      expect(resultado[:status]).to eq(:success)
      expect(resultado[:details][:alunos_criados]).to eq(1)
      expect(resultado[:details][:docentes_criados]).to eq(1)
    end
  end

  # --- SAD PATHS  ---

  context "quando o ficheiro não é um JSON válido" do
    subject(:service) { described_class.new(double(read: "isto nao e um json", original_filename: 'file.json')) }

    it "não cria nenhum usuário" do
      expect { service.call }.not_to change(Usuario, :count)
    end

    it "retorna um resultado de falha com a mensagem de erro de sintaxe" do
      resultado = service.call
      expect(resultado[:errors].first).to eq("Erro: JSON inválido.")
    end
  end

  context "quando nenhum ficheiro é fornecido" do
    subject(:service) { described_class.new(nil) } # Simula a ausência de um ficheiro

    it "não cria nenhum usuário" do
      expect { service.call }.not_to change(Usuario, :count)
    end

    it "retorna um resultado de falha com a mensagem correta" do
      resultado = service.call
      expect(resultado[:success]).to be false
      expect(resultado[:errors]).to include("Nenhum arquivo foi enviado.")
    end
  end

  context "quando um aluno já existente é importado para a mesma turma" do
    let!(:aluno_existente) { FactoryBot.create(:usuario, matricula: "111222", password: "Password@123") }

    let(:dados_com_aluno_existente) do
      [ {
      "code" => disciplina.codigo,
      "classCode" => turma.codigo_turma,
      "semester" => turma.semestre,
      "dicente" => [ { "nome" => "Nome Antigo", "matricula" => "111222", "email" => "aluno.existente@email.com" } ]
      } ]
    end

    subject(:service) { described_class.new(double(read: dados_com_aluno_existente.to_json, original_filename: 'alunos.json')) }


    it "não cria um novo usuário" do
      expect { service.call }.not_to change(Usuario, :count)
    end

    it "não envia um novo e-mail" do
      expect { service.call }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context "quando o ficheiro contém dados de uma turma que não existe" do
    let(:dados_turma_invalida) do
        dados_validos.tap { |d| d.first["classCode"] = "TURMA_FANTASMA" }
    end
    subject(:service) { described_class.new(double(read: dados_turma_invalida.to_json, original_filename: 'alunos.json')) }

    it "não cria nenhum usuário novo" do
        expect { service.call }.not_to change(Usuario, :count)
    end

    it "retorna um status de sucesso parcial com a mensagem de erro correta" do
        resultado = service.call
        expect(resultado[:status]).to eq(:partial_success)
        expect(resultado[:erros].first).to include("Turma TURMA_FANTASMA não encontrada")
    end
  end
end
