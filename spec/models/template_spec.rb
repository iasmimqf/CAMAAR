<<<<<<< HEAD
require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:usuario) { create(:usuario) }

  describe 'validações básicas' do
    it 'é válido com título e criador' do
      template = build(:template, titulo: 'Template Válido', criador: usuario)
      template.skip_questoes_validation = true
      expect(template).to be_valid
    end

    it 'é inválido sem título' do
      template = build(:template, titulo: nil, criador: usuario)
      template.skip_questoes_validation = true
      expect(template).not_to be_valid
      expect(template.errors[:titulo]).to include("O título do template é obrigatório")
    end

    it 'é inválido sem criador' do
      template = build(:template, titulo: 'Template Teste', criador: nil)
      template.skip_questoes_validation = true
      expect(template).not_to be_valid
    end

    it 'é inválido com título duplicado' do
      create(:template, titulo: "Título Único", criador: usuario)
      template_duplicado = build(:template, titulo: "Título Único", criador: usuario)
      template_duplicado.skip_questoes_validation = true
      expect(template_duplicado).not_to be_valid
      expect(template_duplicado.errors[:titulo]).to include("Já existe um template com este nome. Use um título diferente.")
    end
  end

  describe 'validação de questões presentes' do
    context 'quando não há questões' do
      it 'deve ser inválido' do
        template = build(:template, titulo: 'Template sem questões', criador: usuario, skip_questoes_validation: false)
        expect(template).not_to be_valid
        expect(template.errors[:base]).to include("Adicione pelo menos uma questão ao template")
      end
    end

    context 'quando tem questões válidas' do
      it 'deve ser válido' do
        template = build(:template, titulo: 'Template com questões', criador: usuario)
        template.questoes.build(enunciado: 'Qual sua opinião?', tipo: 'Texto')
        expect(template).to be_valid
      end
    end

    context 'quando pula validação de questões' do
      it 'deve ser válido mesmo sem questões' do
        template = build(:template, titulo: 'Template válido', criador: usuario)
        template.skip_questoes_validation = true
        expect(template).to be_valid
      end
=======
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
>>>>>>> 45470b0075447feb0d3b821b202008e316924ac0
    end
  end

  describe 'associações' do
<<<<<<< HEAD
    let(:template) { create(:template, criador: usuario) }

    it 'pertence a um criador (Usuario)' do
      expect(template.criador).to be_a(Usuario)
      expect(template.criador).to eq(usuario)
    end

    it 'pode ter múltiplas questões' do
      questao1 = create(:questao, template: template)
      questao2 = create(:questao, template: template)
      
      expect(template.questoes).to include(questao1, questao2)
      expect(template.questoes.count).to eq(2)
    end

    it 'destroi questões quando template é destruído' do
      questao = create(:questao, template: template)
      questao_id = questao.id
      
      template.destroy
      expect(Questao.find_by(id: questao_id)).to be_nil
    end

    it 'pode ter múltiplos formulários' do
      # Vamos criar um formulário válido com template e turmas
      turma = create(:turma)
      formulario1 = create(:formulario, template: template, turmas: [turma])
      formulario2 = create(:formulario, template: template, turmas: [turma])
      
      expect(template.formularios).to include(formulario1, formulario2)
      expect(template.formularios.count).to eq(2)
    end
  end

  describe 'scopes' do
    let!(:template_com_questoes) do
      template = create(:template, criador: usuario)
      create(:questao, template: template)
      template
    end
    let!(:template_sem_questoes) { create(:template, criador: usuario) }
    let(:outro_usuario) { create(:usuario) }
    let!(:template_outro_criador) do
      template = create(:template, criador: outro_usuario)
      create(:questao, template: template)
      template
    end

    describe '.com_questoes' do
      it 'retorna apenas templates que têm questões' do
        templates_com_questoes = Template.com_questoes
        expect(templates_com_questoes).to include(template_com_questoes, template_outro_criador)
        expect(templates_com_questoes).not_to include(template_sem_questoes)
      end
    end

    describe '.do_criador' do
      it 'retorna templates de um criador específico' do
        templates_do_usuario = Template.do_criador(usuario)
        expect(templates_do_usuario).to include(template_com_questoes, template_sem_questoes)
        expect(templates_do_usuario).not_to include(template_outro_criador)
      end
    end
  end

  describe 'nested attributes' do
    it 'aceita nested attributes para questões' do
      template_params = {
        titulo: 'Template com questões',
        criador: usuario,
        questoes_attributes: {
          '0' => {
            enunciado: 'Qual sua avaliação?',
            tipo: 'Texto',
            obrigatoria: true
          },
          '1' => {
            enunciado: 'Escolha uma opção',
            tipo: 'Escala',
            obrigatoria: false,
            opcoes: '5,4,3,2,1'
          }
        }
      }

      template = Template.new(template_params)
      expect(template).to be_valid
      expect(template.questoes.size).to eq(2)
    end

    it 'permite atualizar questões existentes' do
      template = create(:template, criador: usuario)
      questao = create(:questao, template: template, enunciado: 'Pergunta original')

      template.update(
        questoes_attributes: {
          questao.id.to_s => {
            id: questao.id,
            enunciado: 'Pergunta atualizada',
            tipo: 'Texto'
          }
        }
      )

      questao.reload
      expect(questao.enunciado).to eq('Pergunta atualizada')
    end
  end

  describe 'métodos customizados' do
    let(:template) { create(:template, criador: usuario) }

    it 'retorna número de questões' do
      create_list(:questao, 3, template: template)
      expect(template.questoes.count).to eq(3)
    end

    it 'retorna número de formulários' do
      turma = create(:turma)
      create_list(:formulario, 2, template: template, turmas: [turma])
      expect(template.formularios.count).to eq(2)
    end

    it 'verifica se pode ser excluído (sem formulários)' do
      expect(template.formularios.count).to eq(0)
    end

    it 'verifica se não pode ser excluído (com formulários)' do
      turma = create(:turma)
      create(:formulario, template: template, turmas: [turma])
      expect(template.formularios.count).to eq(1)
    end
=======
    # Usando a gema shoulda-matchers para testes de associação mais limpos e robustos
    # Garanta que a associação no modelo esteja como: belongs_to :criador, class_name: 'Usuario'
    it { should belong_to(:criador).class_name('Usuario') }
    it { should have_many(:questoes).dependent(:destroy) }
    it { should have_many(:formularios).dependent(:restrict_with_error) }
    it { should accept_nested_attributes_for(:questoes) }
>>>>>>> 45470b0075447feb0d3b821b202008e316924ac0
  end
end
