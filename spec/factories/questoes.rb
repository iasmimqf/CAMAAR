# spec/factories/questoes.rb
FactoryBot.define do
  factory :questao do
    enunciado { Faker::Lorem.question }
    tipo { ['Escala', 'Texto'].sample }
    obrigatoria { [true, false].sample }
    opcoes { tipo == 'Escala' ? '5,4,3,2,1' : nil }
    association :template

    # Trait para questão do tipo escala
    trait :escala do
      tipo { 'Escala' }
      opcoes { '5,4,3,2,1' }
    end

    # Trait para questão do tipo texto
    trait :texto do
      tipo { 'Texto' }
      opcoes { nil }
    end

    # Trait para questão obrigatória
    trait :obrigatoria do
      obrigatoria { true }
    end
  end
end
