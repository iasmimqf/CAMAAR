# spec/models/template_spec.rb
require 'rails_helper'

RSpec.describe Template, type: :model do
  # Cria um utilizador admin que será usado em vários testes
  let(:admin) { FactoryBot.create(:usuario, :admin) }

  describe 'validações' do
    # Define o 'sujeito' do teste. Usa 'criador' em vez de 'usuario'.
    subject { FactoryBot.build(:template, criador: admin) }

    it 'é válido com atributos corretos' do
      expect(subject).to be_valid
    end

    it 'é inválido sem um título' do
      subject.titulo = nil
      expect(subject).not_to be_valid
      # A mensagem de erro vem do seu modelo
      expect(subject.errors[:titulo]).to include("O título do template é obrigatório")
    end

    it 'é inválido sem um criador' do
      # Altera a associação 'criador' para nil
      subject.criador = nil
      expect(subject).not_to be_valid
      # Verifica a mensagem de erro para a associação 'criador'
      expect(subject.errors[:criador]).to include("é obrigatório(a)")
    end

    it 'é inválido com um título duplicado' do
      # Usa 'criador' para criar o primeiro template
      FactoryBot.create(:template, titulo: 'Título Único', criador: admin)
      subject.titulo = 'Título Único'
      expect(subject).not_to be_valid
      expect(subject.errors[:titulo]).to include("Já existe um template com este nome. Use um título diferente.")
    end

    it 'é inválido se não tiver nenhuma questão' do
      subject.questoes = [] # Remove a questão padrão da factory
      expect(subject).not_to be_valid
      expect(subject.errors[:base]).to include("Adicione pelo menos uma questão ao template")
    end
  end
  
  describe 'associações' do
    # Usando a gema shoulda-matchers para testes de associação mais limpos e robustos
    # Garanta que a associação no modelo esteja como: belongs_to :criador, class_name: 'Usuario'
    it { should belong_to(:criador).class_name('Usuario') }
    it { should have_many(:questoes).dependent(:destroy) }
    it { should have_many(:formularios).dependent(:restrict_with_error) }
    it { should accept_nested_attributes_for(:questoes) }
  end
end
