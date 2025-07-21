# spec/models/template_spec.rb
require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:admin_user) { create(:usuario, :admin) }

  describe "validations" do
    it "is valid with valid attributes" do
      template = build(:template, criador: admin_user)
      template.skip_questoes_validation = true
      expect(template).to be_valid
    end

    it "is not valid without a titulo" do
      template = build(:template, titulo: nil, criador: admin_user)
      template.skip_questoes_validation = true
      expect(template).not_to be_valid
      expect(template.errors[:titulo]).to include("O título do template é obrigatório")
    end

    it "is not valid with duplicate titulo" do
      create(:template, titulo: "Título Único", criador: admin_user)
      duplicate_template = build(:template, titulo: "Título Único", criador: admin_user)
      duplicate_template.skip_questoes_validation = true
      expect(duplicate_template).not_to be_valid
      expect(duplicate_template.errors[:titulo]).to include("Já existe um template com este nome. Use um título diferente.")
    end
  end

  describe "associations" do
    it "belongs to criador" do
      expect(Template.reflect_on_association(:criador).macro).to eq(:belongs_to)
    end

    it "has many questoes" do
      expect(Template.reflect_on_association(:questoes).macro).to eq(:has_many)
    end

    it "has many formularios" do
      expect(Template.reflect_on_association(:formularios).macro).to eq(:has_many)
    end
  end

  describe "nested attributes" do
    it "accepts nested attributes for questoes" do
      template_attributes = {
        titulo: "Template com questões",
        criador: admin_user,
        questoes_attributes: [
          {
            enunciado: "Questão 1",
            tipo: "Escala",
            obrigatoria: true,
            opcoes: "5,4,3,2,1"
          },
          {
            enunciado: "Questão 2",
            tipo: "Texto",
            obrigatoria: false
          }
        ]
      }

      template = Template.create(template_attributes)
      expect(template).to be_valid
      expect(template.questoes.count).to eq(2)
    end
  end

  describe "question validation" do
    it "allows template without questoes when skip_questoes_validation is true" do
      template = build(:template, criador: admin_user, skip_questoes_validation: true)
      expect(template).to be_valid
    end

    it "is valid with at least one complete questao" do
      template = build(:template, criador: admin_user)
      template.questoes.build(
        enunciado: "Questão válida",
        tipo: "Escala",
        obrigatoria: true,
        opcoes: "5,4,3,2,1"
      )
      expect(template).to be_valid
    end
  end
end
