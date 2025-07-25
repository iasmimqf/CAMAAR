# spec/factories/templates.rb
FactoryBot.define do
  factory :template do
    titulo { Faker::Lorem.sentence(word_count: 3) }
    skip_questoes_validation { true }
    association :criador, factory: :usuario

    trait :with_questions do
      transient do
        questions_count { 2 }
      end

      after(:create) do |template, evaluator|
        create_list(:questao, evaluator.questions_count, template: template)
        template.reload
      end
    end
  end
end
