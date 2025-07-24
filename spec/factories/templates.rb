# spec/factories/templates.rb
FactoryBot.define do
  factory :template do
    titulo { Faker::Lorem.sentence(word_count: 3) }
    skip_questoes_validation { true }
    association :criador, factory: :usuario

    # Cria um template com questões
    trait :com_questoes do
      after(:create) do |template|
        create_list(:questao, 2, template: template)
      end
    end
  end
end
