# spec/services/sigaa_sync_service_spec.rb
require 'rails_helper'

RSpec.describe SigaaSyncService, type: :service do
  # Cria uma turma e uma disciplina de base para os testes
  let!(:disciplina) { FactoryBot.create(:disciplina, codigo: 'MAT0030', nome: 'Cálculo 1') }
  let!(:turma) { FactoryBot.create(:turma, disciplina: disciplina, codigo_turma: 'A', semestre: '2021.2', horario: '35M12' ) }

  # Simula os dados que viriam do arquivo JSON de alunos
  let(:dados_de_importacao) do
    {
      "code" => 'MAT0030',
      "classCode" => 'A',
      "semester" => turma.semestre,
      "dicente" => [
        { "nome" => "Professor Novo", "matricula" => "999999", "email" => "novo.aluno@email.com" }
      ]
    }
  end

  # O método que estamos testando será o .perform
  subject(:service) { described_class.new(dados_de_importacao) }

  # --- HAPPY PATH ---
  context "quando um novo usuário é importado" do
    it "cria um novo usuário no banco de dados" do
      expect { service.perform }.to change(Usuario, :count).by(1)
    end

    it "associa o novo usuário à turma correta" do
      service.perform
      novo_usuario = Usuario.find_by(email: "novo.aluno@email.com")
      expect(turma.usuarios).to include(novo_usuario)
    end

    it "envia um e-mail de definição de senha para o novo usuário" do
      # Verifica se o número de e-mails na "fila de entrega" aumenta em 1
      expect { service.perform }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end

  # --- SAD PATHS ---
  context "quando um usuário já existente é importado" do
    # Cria o usuário ANTES de rodar o teste
    let!(:usuario_existente) { FactoryBot.create(:usuario, email: 'aluno.antigo@email.com', password: 'Password@123') }

    before do
      # Adiciona o usuário existente aos dados de importação
      dados_de_importacao["dicente"] = [{ "email" => "aluno.antigo@email.com", "matricula" => usuario_existente.matricula, "nome" => "Nome Antigo" }]
    end

    it "NÃO envia um e-mail de definição de senha" do
      # Verifica se o número de e-mails na fila NÃO MUDA
      expect { service.perform }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context "quando os dados do usuário são inválidos" do
    before do
      # Dados inválidos (e-mail em branco)
      dados_de_importacao["dicente"] = [{ "email" => "", "matricula" => "123123", "nome" => "Invalido" }]
    end

    it "não cria um novo usuário" do
      expect { service.perform }.not_to change(Usuario, :count)
    end

    it "não envia nenhum e-mail" do
      expect { service.perform }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context "quando a turma no arquivo não existe" do
    before do
      # Dados apontando para uma turma que não existe no banco
      dados_de_importacao["classCode"] = "TURMA_FANTASMA"
    end

    it "não cria um novo usuário" do
      expect { service.perform }.not_to change(Usuario, :count)
    end
  end
end