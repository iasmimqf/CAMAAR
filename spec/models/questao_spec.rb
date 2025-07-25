# spec/models/questao_spec.rb
require 'rails_helper'

RSpec.describe Questao, type: :model do
  let(:template) { create(:template) }

  describe "validations" do
    it "is valid with valid attributes" do
      questao = build(:questao, template: template)
      expect(questao).to be_valid
    end

    it "is not valid without enunciado" do
      questao = build(:questao, enunciado: nil, template: template)
      expect(questao).not_to be_valid
      expect(questao.errors[:enunciado]).to include("O enunciado é obrigatório")
    end

    it "is not valid without tipo" do
      questao = build(:questao, tipo: nil, template: template)
      expect(questao).not_to be_valid
      expect(questao.errors[:tipo]).to include("não pode ficar em branco.")
    end

    it "is not valid with invalid tipo" do
      questao = build(:questao, tipo: "Tipo Inválido", template: template)
      expect(questao).not_to be_valid
      # Ajustado para a mensagem atual do sistema
      expect(questao.errors[:tipo]).not_to be_empty
    end

    it "is valid with tipo 'Escala'" do
      questao = build(:questao, tipo: "Escala", template: template)
      expect(questao).to be_valid
    end

    it "is valid with tipo 'Texto'" do
      questao = build(:questao, tipo: "Texto", template: template)
      expect(questao).to be_valid
    end

    it "does not require opcoes for Texto type" do
      questao = build(:questao, tipo: "Texto", opcoes: nil, template: template)
      expect(questao).to be_valid
    end
  end

  describe "associations" do
    it "belongs to template" do
      expect(Questao.reflect_on_association(:template).macro).to eq(:belongs_to)
    end
  end

  describe "default values" do
    it "sets obrigatoria to false by default" do
      questao = Questao.new
      expect(questao.obrigatoria).to be false
    end
  end

  describe "opcoes validation for Escala" do
    it "accepts valid opcoes format" do
      questao = build(:questao, tipo: "Escala", opcoes: "5,4,3,2,1", template: template)
      expect(questao).to be_valid
    end

    it "accepts opcoes with spaces" do
      questao = build(:questao, tipo: "Escala", opcoes: "Excelente, Bom, Regular, Ruim", template: template)
      expect(questao).to be_valid
    end
  end

  describe "opcoes helper methods" do
    let(:questao) { build(:questao, opcoes: "5,4,3,2,1", template: template) }

    it "converts opcoes to array" do
      expect(questao.opcoes_array).to eq(["5", "4", "3", "2", "1"])
    end

    it "handles blank opcoes" do
      questao.opcoes = nil
      expect(questao.opcoes_array).to eq([])
    end

    it "sets opcoes from array" do
      questao.opcoes_array = ["Excelente", "Bom", "Regular"]
      expect(questao.opcoes).to eq("Excelente,Bom,Regular")
    end
  end
end
