# spec/models/formulario_spec.rb
require 'rails_helper'

RSpec.describe Formulario, type: :model do
  # Cria os dados base que serão usados em vários testes
  let(:admin) { FactoryBot.create(:usuario, :admin) }
  let(:template_obj) { FactoryBot.create(:template, criador: admin) }
  let(:turma) { FactoryBot.create(:turma) }

  describe 'validações' do
    # Define o 'sujeito' do teste para evitar repetição
    subject { FactoryBot.build(:formulario, template: template_obj, turmas: [turma], criador: admin) }

    it 'é válido com todos os atributos corretos' do
      expect(subject).to be_valid
    end
    
    it 'é inválido sem um template' do
      subject.template = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:template]).to include("é obrigatório(a)")
    end
    
    it 'é inválido se não tiver turmas' do
      subject.turmas = []
      expect(subject).not_to be_valid
      expect(subject.errors[:turmas]).to include("Você deve selecionar ao menos uma turma")  
    end
  end
  
  describe 'associações' do
    # Usando shoulda-matchers para testes de associação limpos
    it { should belong_to(:template) }
    it { should belong_to(:criador).class_name('Usuario') }
    it { should have_and_belong_to_many(:turmas) }
  end
end
