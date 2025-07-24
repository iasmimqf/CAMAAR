FactoryBot.define do
  factory :template do
    titulo { Faker::Lorem.sentence(word_count: 3) }
    skip_questoes_validation { true }
    association :criador, factory: :usuario

    # Cria um template com pelo menos uma questão para passar na validação
    after(:build) do |template|
      template.questoes << build(:questao, template: template) if template.questoes.empty?
    end

    # Trait para criar um template com múltiplas questões
    trait :with_multiple_questions do
      after(:build) do |template|
        template.questoes.destroy_all # Limpa a questão padrão
        template.questoes << build(:questao, enunciado: "Questão Obrigatória", obrigatoria: true, tipo: 'Texto', template: template)
        template.questoes << build(:questao, enunciado: "Questão de Escala", obrigatoria: false, tipo: 'Escala', opcoes: '5,4,3,2,1', template: template)
      end
    end
  end
end
