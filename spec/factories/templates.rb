# spec/factories/templates.rb
FactoryBot.define do
  factory :template do
    titulo { Faker::Lorem.sentence(word_count: 3) }
    association :criador, factory: :usuario
    skip_questoes_validation { true }

    # Cria um template com questões
    trait :com_questoes do
      after(:create) do |template|
        create_list(:questao, 2, template: template)
      end
    end
  end
end
