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
        template = build(:template, titulo: 'Template sem questões', criador: usuario)
        expect(template).not_to be_valid
        expect(template.errors[:questoes]).to include("O template deve ter pelo menos uma questão")
      end
    end

    context 'quando tem questões válidas' do
      it 'deve ser válido' do
        template = build(:template, titulo: 'Template com questões', criador: usuario)
        template.questoes.build(pergunta: 'Qual sua opinião?', tipo: 'text')
        expect(template).to be_valid
      end
    end

    context 'quando pula validação de questões' do
      it 'deve ser válido mesmo sem questões' do
        template = build(:template, titulo: 'Template válido', criador: usuario)
        template.skip_questoes_validation = true
        expect(template).to be_valid
      end
    end
  end

  describe 'associações' do
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
      formulario1 = create(:formulario, template: template)
      formulario2 = create(:formulario, template: template)
      
      expect(template.formularios).to include(formulario1, formulario2)
      expect(template.formularios.count).to eq(2)
    end
  end

  describe 'scopes' do
    let!(:template_com_questoes) { create(:template_with_questoes, criador: usuario) }
    let!(:template_sem_questoes) { create(:template, criador: usuario) }
    let(:outro_usuario) { create(:usuario) }
    let!(:template_outro_criador) { create(:template_with_questoes, criador: outro_usuario) }

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
            pergunta: 'Qual sua avaliação?',
            tipo: 'text',
            obrigatoria: true
          },
          '1' => {
            pergunta: 'Escolha uma opção',
            tipo: 'multiple',
            obrigatoria: false
          }
        }
      }

      template = Template.new(template_params)
      expect(template).to be_valid
      expect(template.questoes.size).to eq(2)
    end

    it 'permite atualizar questões existentes' do
      template = create(:template, criador: usuario)
      questao = create(:questao, template: template, pergunta: 'Pergunta original')

      template.update(
        questoes_attributes: {
          questao.id.to_s => {
            id: questao.id,
            pergunta: 'Pergunta atualizada',
            tipo: 'text'
          }
        }
      )

      questao.reload
      expect(questao.pergunta).to eq('Pergunta atualizada')
    end
  end

  describe 'métodos customizados' do
    let(:template) { create(:template, criador: usuario) }

    it 'retorna número de questões' do
      create_list(:questao, 3, template: template)
      expect(template.numero_questoes).to eq(3)
    end

    it 'retorna número de formulários' do
      create_list(:formulario, 2, template: template)
      expect(template.numero_formularios).to eq(2)
    end

    it 'verifica se pode ser excluído (sem formulários)' do
      expect(template.pode_ser_excluido?).to be true
    end

    it 'verifica se não pode ser excluído (com formulários)' do
      create(:formulario, template: template)
      expect(template.pode_ser_excluido?).to be false
    end
  end
end
